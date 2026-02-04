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

import 'package:valkey_client/valkey_client.dart';

Future<void> main() async {
  final client = ValkeyClient(host: 'localhost', port: 6379);
  await client.connect();
  await client.flushAll();

  print('--- 🏆 Sorted Set (Leaderboard) Example ---\n');

  // 1. Basic Score Management (ZADD, ZINCRBY, ZSCORE)
  print('1. Setting up leaderboard...');
  // Add players with initial scores
  await client.zAdd('leaderboard:wk1', {
    'PlayerA': 100,
    'PlayerB': 200,
    'PlayerC': 150,
    'PlayerD': 50,
  });

  // PlayerA levels up (+50 points)
  final newScore = await client.zIncrBy('leaderboard:wk1', 50, 'PlayerA');
  print('   PlayerA new score: $newScore'); // 150

  final scoreC = await client.zScore('leaderboard:wk1', 'PlayerC');
  print('   PlayerC current score: $scoreC');

  // 2. Ranking and Ranges (ZRANK, ZRANGE)
  print('\n2. Checking ranks...');
  // Rank (0-based, low to high)
  final rankD = await client.zRank('leaderboard:wk1', 'PlayerD');
  print('   PlayerD Rank (Ascending): $rankD'); // 0 (lowest score)

  // RevRank (0-based, high to low - standard leaderboard)
  final rankB = await client.zRevRank('leaderboard:wk1', 'PlayerB');
  print('   PlayerB Rank (Descending): $rankB'); // 0 (1st place)

  // Get Top 3 Players (High to Low)
  final top3 =
      await client.zRange('leaderboard:wk1', 0, 2, rev: true, withScores: true);
  print('   Top 3: $top3'); // [PlayerB, 200, PlayerA, 150, PlayerC, 150]

  // 3. Set Operations (ZINTER, ZUNION)
  print('\n3. Tournament Results (Inter/Union)...');
  await client
      .zAdd('leaderboard:wk2', {'PlayerA': 200, 'PlayerB': 100, 'Newbie': 300});

  // Sum scores for players who played both weeks
  final totalScores = await client.zInter(
    ['leaderboard:wk1', 'leaderboard:wk2'],
    aggregate: 'SUM',
    withScores: true,
  );
  print('   Combined Scores (A & B): $totalScores');

  // 4. Advanced ranges (Lexicographical, Score)
  print('\n4. Advanced Queries...');
  await client.zAdd('words', {
    'apple': 0,
    'banana': 0,
    'cherry': 0,
    'date': 0
  }); // All scores 0 for Lex search

  final rangeLex = await client.zRange('words', '[a', '[c', byLex: true);
  print('   Words from a to c: $rangeLex'); // [apple, banana]

  final countScore = await client.zCount('leaderboard:wk1', 100, 200);
  print('   Players with score 100~200: $countScore');

  // 5. Popping & Blocking (ZMPOP, BZPOPMAX)
  print('\n5. Popping winners...');
  // Pop the highest score from wk2
  final winner = await client.zPopMax('leaderboard:wk2');
  print('   Week 2 Winner (Removed): $winner'); // [Newbie, 300]

  // Blocking Pop (Wait for data if empty)
  // Here we use existing data so it returns immediately
  final blockedPop = await client.bzPopMax(['leaderboard:wk1'], 1.0);
  print('   Blocked Pop Result: $blockedPop');

  // 6. Removing (ZREM)
  final removed = await client.zRem('words', ['apple']);
  print('   Removed "apple". Remaining count: ${await client.zCard("words")}');
  print('   zRem Result: $removed');

  await client.close(); // disconnect
  print('\n--- Done ---');
}
