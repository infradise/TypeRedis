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

import 'dart:async';
import 'package:typeredis/typeredis.dart';

Future<void> main() async {
  final client = TRClient(host: 'localhost', port: 6379);
  await client.connect();

  print('--- 🚀 Hash Commands Example: User Profile ---\n');

  const userId = 'user:1001';

  // 1. Create a user profile (HSET)
  print('1. Creating user profile...');
  await client.hSet(userId, {
    'username': 'dart_dev',
    'email': 'dev@example.com',
    'logins': '0',
    'status': 'active',
    'last_seen': DateTime.now().toIso8601String(),
  });

  // 2. Retrieve entire profile (HGETALL)
  final profile = await client.hGetAll(userId);
  print('2. User Profile: $profile');

  // 3. Increment login count (HINCRBY)
  final newLogins = await client.hIncrBy(userId, 'logins', 1);
  print('3. New Login Count: $newLogins');

  // 4. Update specific fields (HSETNX - only if not exists)
  // Trying to overwrite username (should fail)
  await client.hSetNx(userId, 'username', 'hacker');
  // Setting a new field 'theme' (should success)
  await client.hSetNx(userId, 'theme', 'dark');

  final theme = await client.hGet(userId, 'theme');
  print('4. User Theme: $theme (Username is still: ${profile['username']})');

  // 5. Field Expiration (Valkey Feature)
  // Set the 'status' field to expire in 5 seconds (Simulating temporary status)
  print('5. Setting "status" field to expire in 5 seconds...');
  await client.hExpire(userId, 5, fields: ['status']);

  // Check TTL
  final ttl = await client.hTtl(userId, ['status']);
  print('   -> TTL for status: ${ttl[0]} seconds');

  // 6. Check Existence (HEXISTS)
  final hasEmail = await client.hExists(userId, 'email');
  print('6. Has Email? $hasEmail');

  // 7. Get specific multiple fields (HMGET)
  final selected = await client.hMGet(userId, ['username', 'logins']);
  print('7. Username & Logins: $selected');

  // 8. Delete a field (HDEL)
  await client.hDel(userId, ['last_seen']);
  print('8. Deleted "last_seen" field.');

  // 9. Scan for debugging (HSCAN)
  print('9. Scanning fields in hash:');
  final scanResult = await client.hScan(userId, '0');
  final fields = scanResult[1] as List;
  for (var i = 0; i < fields.length; i += 2) {
    print('   - ${fields[i]}: ${fields[i + 1]}');
  }

  // Cleanup
  await client.del([userId]);
  await client.close(); // disconnect()
  print('\n--- Done ---');
}
