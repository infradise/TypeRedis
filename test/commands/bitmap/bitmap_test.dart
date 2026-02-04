/*
 * Copyright 2025-2026 Infradise Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:test/test.dart';
import 'package:typeredis/typeredis.dart';

void main() {
  group('Bitmap Commands', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close();
    });

    test('SETBIT & GETBIT', () async {
      const key = 'bit:test';

      // 1. Initial Set (returns old value 0)
      final oldVal1 = await client.setBit(key, 7, 1);
      expect(oldVal1, equals(0));

      // 2. Get Bit
      expect(await client.getBit(key, 7), equals(1));
      expect(await client.getBit(key, 0), equals(0)); // Unset bit

      // 3. Update Set (returns old value 1)
      final oldVal2 = await client.setBit(key, 7, 0);
      expect(oldVal2, equals(1));
      expect(await client.getBit(key, 7), equals(0));
    });

    test('BITCOUNT', () async {
      const key = 'bit:count';
      // Set bits at 0, 1, 2, 8 (2 bytes involved)
      // Byte 0: 11100000 (bits 0,1,2 set) -> 3 bits
      // Byte 1: 10000000 (bit 8 set) -> 1 bit
      await client.setBit(key, 0, 1);
      await client.setBit(key, 1, 1);
      await client.setBit(key, 2, 1);
      await client.setBit(key, 8, 1);

      // 1. Total Count
      expect(await client.bitCount(key), equals(4));

      // 2. Range Count (Byte mode)
      // Byte 0 only
      expect(await client.bitCount(key, start: 0, end: 0), equals(3));
      // Byte 1 only
      expect(await client.bitCount(key, start: 1, end: 1), equals(1));
    });

    test('BITPOS', () async {
      const key = 'bit:pos';
      // Bits: 0000... (until 100) ... 1
      await client.setBit(key, 100, 1);

      // 1. Find first 1
      expect(await client.bitPos(key, 1), equals(100));

      // 2. Find first 0
      expect(await client.bitPos(key, 0), equals(0));

      // 3. Find first 1 with start byte
      // bit 100 is in byte 12 (100 / 8 = 12.5)
      // If we search from byte 13, we shouldn't find it inside byte 12?
      // Actually bit 100 is: byte index 12, bit index 4 (12*8 + 4 = 100)

      // Search from byte 0 to 11 (should be -1 as bit 100 is at byte 12)
      expect(await client.bitPos(key, 1, start: 0, end: 11), equals(-1));

      // Search from byte 12
      expect(await client.bitPos(key, 1, start: 12), equals(100));
    });

    test('BITOP', () async {
      const key1 = 'bit:op1'; // 00001111 (integer 15)
      const key2 = 'bit:op2'; // 00110011 (integer 51)

      // Set raw bytes, but using setBit is safer for test readability
      // Key1: ...00001
      await client.setBit(key1, 0, 1);
      // Key2: ...00000
      await client.setBit(key2, 0, 0);

      // 1. OR (1 | 0 = 1)
      await client.bitOp('OR', 'dest:or', [key1, key2]);
      expect(await client.getBit('dest:or', 0), equals(1));

      // 2. AND (1 & 0 = 0)
      await client.bitOp('AND', 'dest:and', [key1, key2]);
      expect(await client.getBit('dest:and', 0), equals(0));

      // 3. XOR (1 ^ 0 = 1)
      await client.bitOp('XOR', 'dest:xor', [key1, key2]);
      expect(await client.getBit('dest:xor', 0), equals(1));

      // 4. NOT
      await client.bitOp('NOT', 'dest:not', [key1]);
      // ~1 = 0
      // Note: NOT creates a string of same length.
      // If bit 0 was 1, result bit 0 is 0.
      expect(await client.getBit('dest:not', 0), equals(0));
    });

    test('BITFIELD', () async {
      const key = 'bit:field';

      // 1. SET / GET
      // u8 at offset 0, set to 255 (max unsigned 8bit)
      final res1 = await client.bitField(key, [
        BitFieldOp.set('u8', 0, 255),
        BitFieldOp.get('u8', 0),
      ]);

      expect(res1, isA<List>());
      expect(res1[0], equals(0)); // Old value
      expect(res1[1], equals(255)); // New value read back

      // 2. INCRBY & OVERFLOW
      // i8 at offset 0 (currently 255 interpreted as -1 in signed 8bit?
      // No, we set u8=255)
      // Let's use a fresh offset.
      // i8 at offset 8, set to 120.
      await client.bitField(key, [BitFieldOp.set('i8', 8, 120)]);

      // Incr by 10 -> 130.
      // Signed 8-bit max is 127. 130 overflows.
      // Default overflow is WRAP.
      // 127 + 1 = -128...

      final res2 = await client.bitField(key, [BitFieldOp.incrBy('i8', 8, 10)]);
      // 120 + 10 = 130.
      // 8-bit Signed binary: 10000010 -> -126
      expect(res2[0], equals(-126));

      // 3. OVERFLOW SAT (Saturation)
      final res3 = await client.bitField(key, [
        BitFieldOp.overflow('SAT'),
        BitFieldOp.incrBy('i8', 8, 1000) // Try to add huge number
      ]);
      // Should saturate at max (127)
      expect(res3[0], equals(127));
    });

    test('BITFIELD_RO', () async {
      const key = 'bit:field_ro';
      await client.setBit(key, 0, 1); // 10000000 = 128 (u8)

      // Only GET allowed
      final res = await client.bitFieldRo(key, [BitFieldOp.get('u8', 0)]);

      expect(res, hasLength(1));
      expect(res[0], equals(128)); // Bit 0 set in byte means 128

      // Should throw if SET is attempted (logic inside client wrapper)
      expect(
        () => client.bitFieldRo(key, [BitFieldOp.set('u8', 0, 1)]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
