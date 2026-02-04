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

  print('--- 📊 Sorted Set Advanced Operations (Store, Range, Utils) ---\n');

  // Setup Data
  await client.zAdd('z1', {'a': 1, 'b': 2, 'c': 3});
  await client.zAdd('z2', {'b': 2, 'c': 4, 'd': 5});

  // 1. ZMSCORE (Get specific scores)
  final mScores = await client.zMScore('z1', ['a', 'c', 'missing']);
  print('1. ZMSCORE (a, c, missing): $mScores'); // [1.0, 3.0, null]

  // 2. ZINTERCARD (Cardinality of intersection)
  final interCard = await client.zInterCard(['z1', 'z2']);
  print('2. ZINTERCARD (z1 ∩ z2 count): $interCard'); // 2 (b, c)

  // 3. STORE Operations (Diff, Inter, Union)
  print('\n3. Store Operations...');

  // ZDIFFSTORE (z1 - z2) -> {a}
  await client.zDiffStore('dest:diff', ['z1', 'z2']);
  print('   ZDIFFSTORE Result: '
      '${await client.zRange("dest:diff", 0, -1, withScores: true)}');

  // ZINTERSTORE (z1 ∩ z2) -> {b:4 (2+2), c:7 (3+4)} (Default SUM)
  await client.zInterStore('dest:inter', ['z1', 'z2']);
  print('   ZINTERSTORE Result: '
      '${await client.zRange("dest:inter", 0, -1, withScores: true)}');

  // ZUNIONSTORE (z1 U z2)
  await client.zUnionStore('dest:union', ['z1', 'z2']);
  print('   ZUNIONSTORE Count: ${await client.zCard("dest:union")}');

  // 4. RANGE Operations (ByScore, ByLex, Store)
  print('\n4. Range Operations...');

  // ZRANGESTORE (Store range 1-2 to new key)
  // Store top 2 members of z1 to 'dest:range'
  await client.zRangeStore('dest:range', 'z1', 0, 1, rev: true);
  print('   ZRANGESTORE (Top 2 of z1): '
      '${await client.zRange("dest:range", 0, -1)}');

  // ZRANGEBYSCORE / ZREVRANGEBYSCORE
  final rangeByScore = await client.zRangeByScore('z1', 1, 2, withScores: true);
  print('   ZRANGEBYSCORE (1 <= score <= 2): $rangeByScore');

  final revRangeByScore = await client.zRevRangeByScore('z1', 3, 2);
  print('   ZREVRANGEBYSCORE (3 >= score >= 2): $revRangeByScore');

  // 5. LEX Operations (Lexicographical)
  // For Lex ops, scores must be identical.
  await client.zAdd(
      'zlex', {'apple': 0, 'banana': 0, 'cherry': 0, 'date': 0, 'egg': 0});
  print('\n5. Lex Operations (Scores must be 0)...');

  // ZRANGEBYLEX ([b, [d)
  final rangeByLex = await client.zRangeByLex('zlex', '[b', '[d');
  print('   ZRANGEBYLEX [b, [d: $rangeByLex'); // banana, cherry, date

  // ZREVRANGEBYLEX ([d, [b) - High to Low
  final revRangeByLex = await client.zRevRangeByLex('zlex', '[d', '[b');
  print('   ZREVRANGEBYLEX [d, [b: $revRangeByLex'); // date, cherry, banana

  // ZLEXCOUNT
  final lexCount = await client.zLexCount('zlex', '[a', '[c');
  print('   ZLEXCOUNT [a, [c: $lexCount'); // 3 (apple, banana, cherry)

  // 6. Random & Scan
  print('\n6. Random & Scan...');

  // ZRANDMEMBER
  final randomMembers = await client.zRandMember('zlex', count: 2);
  print('   ZRANDMEMBER (2 items): $randomMembers');

  // ZSCAN
  final scanRes = await client.zScan('z1', 0);
  print('   ZSCAN result: ${scanRes[1]}');

  await client.close(); // disconnect
}
