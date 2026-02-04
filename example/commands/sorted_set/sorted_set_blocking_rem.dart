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

  print('--- 🧱 Sorted Set Blocking & Removal Example ---\n');

  // Setup Data
  await client.zAdd(
      'tasks', {'task1': 1, 'task2': 2, 'task3': 3, 'task4': 4, 'task5': 5});
  await client.zAdd('urgent', {'job1': 100});

  // 1. Blocking Pop Operations
  print('1. Blocking Pop Operations...');

  // BZPOPMIN (Pop lowest score from 'tasks', wait up to 2s)
  // Returns: [key, member, score]
  final bzMin = await client.bzPopMin(['tasks'], 2.0);
  print('   BZPOPMIN (tasks): $bzMin'); // [tasks, task1, 1]

  // BZMPOP (Pop highest score from first non-empty key)
  // Checks 'urgent' first, then 'tasks'.
  // Returns: [key, [[member, score]]]
  final bzMpop = await client.bzMPop(2.0, ['urgent', 'tasks'], 'MAX', count: 1);
  print('   BZMPOP (MAX from urgent): $bzMpop');
  // Result: [urgent, [[job1, 100]]] (Removed job1)

  // 2. Removal by Range Operations
  print('\n2. Removal by Range...');

  // Setup for removal
  await client.zAdd('rem_test', {'a': 10, 'b': 20, 'c': 30, 'd': 40, 'e': 50});

  // ZREMRANGEBYSCORE (Remove scores 10 to 20) -> a, b removed
  final remScoreCount = await client.zRemRangeByScore('rem_test', 10, 20);
  print('   ZREMRANGEBYSCORE (10~20): Removed $remScoreCount items');
  // Remaining: c(30), d(40), e(50)

  // ZREMRANGEBYRANK (Remove rank 0 to 0) -> c removed (lowest score is rank 0)
  final remRankCount = await client.zRemRangeByRank('rem_test', 0, 0);
  print('   ZREMRANGEBYRANK (Rank 0): Removed $remRankCount items');
  // Remaining: d(40), e(50)

  // Setup for Lex removal (Scores must be same)
  await client.del(['rem_lex']);
  await client
      .zAdd('rem_lex', {'alpha': 0, 'bravo': 0, 'charlie': 0, 'delta': 0});

  // ZREMRANGEBYLEX (Remove [bravo, [charlie])
  final remLexCount =
      await client.zRemRangeByLex('rem_lex', '[bravo', '[charlie');
  print('   ZREMRANGEBYLEX [bravo, [charlie: Removed $remLexCount items');
  // Remaining: alpha, delta

  final remaining = await client.zRange('rem_lex', 0, -1);
  print('   Remaining members in rem_lex: $remaining');

  await client.close(); // disconnect
}
