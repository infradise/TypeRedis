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

  // Clean up before starting
  await client.flushAll();

  print('--- 🚀 List Advanced Commands Example ---\n');

  const key = 'adv_list';
  const destKey = 'dest_list';

  // 1. LPUSHX / RPUSHX (Push only if exists)
  // Should fail (return 0) because key doesn't exist
  final lenX1 = await client.lPushX(key, ['A']);
  print('1. LPUSHX on missing key: $lenX1 (Expected 0)');

  await client.lPush(key, ['Base']);
  // Should succeed now
  final lenX2 = await client.rPushX(key, ['Tail']);
  print('   RPUSHX on existing key: $lenX2 (List: [Base, Tail])');

  // 2. LINSERT, LSET, LINDEX
  // List: [Base, Tail] -> Insert 'Mid' BEFORE 'Tail'
  await client.lInsert(key, 'BEFORE', 'Tail', 'Mid');
  print('2. LINSERT: Inserted Mid. List is now [Base, Mid, Tail]');

  // Update index 0
  await client.lSet(key, 0, 'Head');
  final valAt0 = await client.lIndex(key, 0);
  print('   LSET/LINDEX: Index 0 updated to $valAt0');

  // 3. LPOS (Position)
  await client.rPush(key, ['Head', 'dup', 'Head']); // Add duplicates
  // List: [Head, Mid, Tail, Head, dup, Head]
  final pos = await client.lPos(key, 'Head', rank: 2); // Find 2nd occurrence
  print('3. LPOS: 2nd occurrence of "Head" is at index $pos');

  // 4. LREM (Remove)
  // Remove all occurrences of 'Head'
  final removed = await client.lRem(key, 0, 'Head');
  print('4. LREM: Removed $removed occurrences of "Head"');

  // 5. LTRIM (Cap the list)
  // List: [Mid, Tail, dup]
  await client.lTrim(key, 0, 1); // Keep only first 2
  print('5. LTRIM: Kept top 2 elements.');

  // 6. RPOPLPUSH (Legacy Move)
  // Move from adv_list to dest_list
  final movedVal = await client.rPopLPush(key, destKey);
  print('6. RPOPLPUSH: Moved "$movedVal" to $destKey');

  // 7. LMPOP (Multi-Pop)
  await client.rPush(key, ['1', '2', '3', '4']);
  // Pop 2 elements from LEFT
  final mPopRes = await client.lMPop([key], 'LEFT', count: 2);
  // Response format: [key, [val1, val2]]
  print('7. LMPOP: Popped $mPopRes');

  // 8. Blocking Commands (Simulating Timeout/Success)
  print('\n--- Blocking Operations (Short Timeout) ---');

  // 8-1. BRPOP
  // List is not empty, returns immediate
  final bRes = await client.bRPop([key], 1);
  print('8-1. BRPOP: $bRes');

  // 8-2. BRPOPLPUSH (Legacy Blocking Move)
  // key is likely empty or has few items. Let's make sure it has one.
  await client.lPush(key, ['ForMove']);
  final bMoveOld = await client.bRPopLPush(key, destKey, 1);
  print('8-2. BRPOPLPUSH: $bMoveOld');

  // 8-3. BLMOVE (Modern Blocking Move)
  // Move from destKey back to key
  final bMoveNew = await client.bLMove(destKey, key, 'LEFT', 'RIGHT', 1);
  print('8-3. BLMOVE: Moved "$bMoveNew" back');

  // 8-4. BLMPOP (Blocking Multi Pop)
  // Wait for data on missing_key (will timeout)
  print('8-4. BLMPOP: Waiting for data on "missing_key" (expect null)...');
  final bMpopRes = await client.bLMPop(1.0, ['missing_key'], 'LEFT', count: 1);
  print('     Result: $bMpopRes');

  await client.close(); // disconnect
  print('\n--- Done ---');
}
