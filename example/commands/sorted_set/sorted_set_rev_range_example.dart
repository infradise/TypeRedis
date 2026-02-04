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

  print('--- 📉 ZRevRangeByScore Example ---\n');

  // Setup: Product Prices (Score = Price)
  // We want to query from Expensive -> Cheap
  await client.zAdd('products', {
    'Laptop': 1500,
    'Smartphone': 900,
    'Tablet': 600,
    'Headphones': 200,
    'Mouse': 50,
  });

  print('Data prepared: '
      'Laptop(1500), Phone(900), Tablet(600), Headphones(200), Mouse(50)\n');

  // 1. Basic Usage: Range by Score (High -> Low)
  // Syntax: ZREVRANGEBYSCORE key max min
  // Find products between 1000 and 500
  print('1. Products between 1000 and 500 (Descending):');

  final midRange = await client.zRevRangeByScore(
      'products',
      1000, // Max
      500 // Min
      );
  print('   Result: $midRange'); // Expected: [Smartphone, Tablet]

  // 2. Using Infinity (+inf, -inf)
  // Find everything cheaper than 800
  print('\n2. Products cheaper than 800 (Max: 800, Min: -inf):');

  final cheapItems = await client.zRevRangeByScore(
      'products',
      800, // Max
      double.negativeInfinity // Min (-inf)
      );
  print('   Result: $cheapItems'); // [Tablet, Headphones, Mouse]

  // 3. With Scores
  print('\n3. Get items with prices (Max: +inf, Min: 1000):');

  final expensiveItems = await client.zRevRangeByScore(
      'products',
      double.infinity, // Max (+inf)
      1000, // Min
      withScores: true);
  print('   Result: $expensiveItems'); // [Laptop, 1500.0]

  // 4. With Limit (Pagination)
  // Get top 3 most expensive items
  print('\n4. Top 3 most expensive (Using LIMIT):');

  final top3 = await client.zRevRangeByScore(
      'products',
      '+inf', // Pass string '+inf', otherwise use double.infinity
      '-inf',
      offset: 0,
      count: 3);
  print('   Result: $top3'); // [Laptop, Smartphone, Tablet]

  await client.close(); // disconnect
  print('\n--- Done ---');
}
