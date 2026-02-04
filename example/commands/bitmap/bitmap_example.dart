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

import 'package:typeredis/typeredis.dart';

Future<void> main() async {
  final client = TRClient(host: 'localhost', port: 6379);
  await client.connect();
  await client.flushAll();

  print('--- [0/1] Bitmap Examples ---\n');

  // Scenario 1: User Online Status & Daily Active Users (DAU)
  // Let's say User ID 10, 15, 20 are active today.
  // We use the date as the key: 'login:2026-02-05'
  print('1. Tracking Daily Active Users (SETBIT, BITCOUNT)...');

  const todayKey = 'login:2026-02-05';
  await client.setBit(todayKey, 10, 1); // User 10 Login
  await client.setBit(todayKey, 15, 1); // User 15 Login
  await client.setBit(todayKey, 20, 1); // User 20 Login

  // Check if User 10 is online
  final isUser10Online = await client.getBit(todayKey, 10);
  print('   User 10 logged in? ${isUser10Online == 1}'); // true

  // Count total DAU
  final dailyCount = await client.bitCount(todayKey);
  print('   Total Users Today: $dailyCount'); // 3

  // Scenario 2: Weekly Retention Analysis (BITOP)
  // Combine 2 days to find users who logged in BOTH days (AND operation)
  print('\n2. Retention Analysis (BITOP)...');

  const yesterdayKey = 'login:2023-10-26';
  await client.setBit(yesterdayKey, 10, 1); // User 10 logged in yesterday too
  await client.setBit(yesterdayKey, 5, 1); // User 5 logged in yesterday only

  // dest = todayKey AND yesterdayKey
  await client.bitOp('AND', 'retention:2days', [todayKey, yesterdayKey]);

  final retentionCount = await client.bitCount('retention:2days');
  print('   Users active BOTH days (User 10): $retentionCount'); // 1

  // Scenario 3: Finding first empty slot (BITPOS)
  // Useful for finding the first available ID or seat
  print('\n3. Finding first inactive user (BITPOS)...');
  // Users 0-9 are not set, so bit 0 is 0.
  // If we want first bit set to 1:
  final firstActive = await client.bitPos(todayKey, 1);
  print('   First active User ID: $firstActive'); // 10

  // Scenario 4: Compact Storage with BITFIELD
  // Storing RPG Character stats in a single key (Gold, Level, HP)
  // Gold (u16), Level (u8), HP (u16)
  print('\n4. Compact Storage (BITFIELD)...');
  const charKey = 'char:hero:stats';

  // Set Gold=500 (u16 at offset 0), Level=10 (u8 at offset 16)
  await client.bitField(charKey, [
    BitFieldOp.set('u16', 0, 500),
    BitFieldOp.set('u8', 16, 10),
  ]);

  // Level up! (Increment Level by 1)
  final levelUpRes = await client.bitField(charKey, [
    BitFieldOp.incrBy('u8', 16, 1), // Returns new value
  ]);
  print('   Level Up! New Level: ${levelUpRes[0]}'); // 11

  // Read stats back (Gold, Level)
  final stats = await client.bitField(charKey, [
    BitFieldOp.get('u16', 0), // Gold
    BitFieldOp.get('u8', 16), // Level
  ]);
  print('   Current Stats -> Gold: ${stats[0]}, Level: ${stats[1]}');

  await client.close();
  print('\n--- Done ---');
}
