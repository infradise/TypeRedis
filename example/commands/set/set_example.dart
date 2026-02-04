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

  print('--- 🧊 Set Commands Example ---\n');

  // 1. Add Members (SADD)
  print('1. Adding users to sets...');
  await client.sAdd('users:all', ['alice', 'bob', 'charlie', 'dave', 'eve']);
  await client.sAdd('users:premium', ['bob', 'eve']);

  final allCount = await client.sCard('users:all');
  print('   Total Users: $allCount'); // 5

  // 2. Check Membership (SISMEMBER, SMISMEMBER)
  print('\n2. Checking membership...');
  final isPremium = await client.sIsMember('users:premium', 'alice');
  print('   Is Alice premium? $isPremium'); // false

  final status =
      await client.sMIsMember('users:all', ['alice', 'missing_user']);
  print('   Membership check (Alice, Unknown): $status'); // [1, 0]

  // 3. Set Operations (INTER, DIFF, UNION)
  print('\n3. Logical Operations...');

  // Intersection: Who are valid users AND premium?
  final premiumValid = await client.sInter(['users:all', 'users:premium']);
  print('   Valid Premium Users: $premiumValid'); // [bob, eve]

  // Difference: Standard users (All - Premium)
  final standardUsers = await client.sDiff('users:all', ['users:premium']);
  print('   Standard Users: $standardUsers'); // [alice, charlie, dave]

  // Union: Merge two groups
  await client.sAdd('users:archive', ['zombie_user']);
  final totalDatabase = await client.sUnion(['users:all', 'users:archive']);
  print('   Total Database Records: ${totalDatabase.length}');

  // 4. Store Operations (SINTERSTORE, etc)
  print('\n4. Storing results...');
  // Save standard users to a new key
  final storeCount =
      await client.sDiffStore('users:standard', 'users:all', ['users:premium']);
  print('   Saved $storeCount standard users to "users:standard".');

  // 5. Moving & Popping (SMOVE, SPOP)
  print('\n5. Moving and Popping...');
  // Move 'charlie' from standard to premium
  final moved =
      await client.sMove('users:standard', 'users:premium', 'charlie');
  print('   Moved Charlie to premium? $moved');

  // Lucky Draw (Random Pop)
  final winner = await client.sPop('users:all');
  print('   Lucky Draw Winner (Removed): $winner');

  // 6. Random Member (SRANDMEMBER) - Non destructive
  final randomSample = await client.sRandMember('users:premium', 2);
  print('   Random Premium Sample (Kept): $randomSample');

  // 7. Scanning (SSCAN)
  print('\n6. Scanning set...');
  final scanResult = await client.sScan('users:premium', 0);
  print('   Scan result (cursor: ${scanResult[0]}): ${scanResult[1]}');

  await client.close();
  print('\n--- Done ---');
}
