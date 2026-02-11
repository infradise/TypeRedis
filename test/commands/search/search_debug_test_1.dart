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

import 'package:keyscope_client/keyscope_client.dart';
import 'package:test/test.dart';

void main() {
  group('Search Debugging', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      // Drop existing indexes to avoid conflicts
      try {
        await client.ftDropIndex('idx:debug_basic');
        await client.ftDropIndex('idx:debug_options');
        await client.ftDropIndex('idx:debug_raw');
      } catch (_) {}
    });

    tearDown(() async {
      await client.disconnect();
    });

    // TEST 1: Minimal execution without any options
    // If this fails, it might be a RediSearch module version issue
    // or the TEXT type is somehow not supported/recognized.
    test('Step 1: Minimal FT.CREATE (No Options)', () async {
      print('--- Executing Step 1: Minimal Create ---');

      // Command: FT.CREATE idx:debug_basic SCHEMA title TEXT
      // Removed complex options like ON HASH, PREFIX, etc.
      await client.ftCreate(
        'idx:debug_basic',
        schema: ['title', 'TEXT'],
      );

      final info = await client.ftInfo('idx:debug_basic');
      expect(info, isNotEmpty);
      print('>>> Step 1 Success!');
    });

    // TEST 2: Add options one by one
    // If this fails, the issue is likely within the ON HASH or PREFIX syntax.
    test('Step 2: FT.CREATE with Options (Strict String)', () async {
      print('--- Executing Step 2: Create with Options ---');

      // Command: FT.CREATE idx:debug_options ON HASH PREFIX 1 user: SCHEMA
      // name TEXT age NUMERIC
      // The key is to pass numbers ('1') as strings to avoid parsing errors.
      await client.ftCreate(
        'idx:debug_options',
        options: [
          'ON', 'HASH',
          'PREFIX', '1', 'user:' // Pass '1' as String
        ],
        schema: ['name', 'TEXT', 'age', 'NUMERIC'],
      );

      final info = await client.ftInfo('idx:debug_options');
      expect(info, isNotEmpty);
      print('>>> Step 2 Success!');
    });

    // TEST 3: Raw Execute Check (To rule out wrapper function issues)
    test('Step 3: Raw Execute Check', () async {
      print('--- Executing Step 3: Raw Execute ---');

      // Sending via the most primitive method to verify if our wrapper function
      // is constructing the argument list incorrectly.
      await client.execute([
        'FT.CREATE',
        'idx:debug_raw',
        'ON',
        'HASH',
        'SCHEMA',
        'desc',
        'TEXT'
      ]);

      // Cleanup
      await client.ftDropIndex('idx:debug_raw');
      print('>>> Step 3 Success!');
    });
  });
}
