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

Future<void> main() async {
  final client = KeyscopeClient(host: 'localhost', port: 6379);
  await client.connect();

  // Redis Only Feature
  if (!await client.isRedisServer()) {
    // or !await client.isRedis
    print('⚠️  Skipping: This example requires a Redis server.');
    print('   Current server appears to be Valkey or other compatible server.');
    await client.close(); // disconnect
    return;
  }

  await client.flushAll();

  print('--- 📊 Search Advanced Example (Aggregation) ---');

  const indexName = 'idx:orders';

  // 1. Create Index for Aggregation
  // Schema: region (TAG), amount (NUMERIC)
  try {
    await client.ftCreate(
      indexName,
      options: ['ON', 'HASH', 'PREFIX', '1', 'order:'],
      schema: ['region', 'TAG', 'amount', 'NUMERIC'],
    );
  } catch (e) {
    print('Index creation failed: $e');
  }

  // 2. Seed Data
  print('1. Seeding Data...');
  await client.hMSet('order:1', {'region': 'North', 'amount': '100'});
  await client.hMSet('order:2', {'region': 'North', 'amount': '200'});
  await client.hMSet('order:3', {'region': 'South', 'amount': '50'});
  await client.hMSet('order:4', {'region': 'East', 'amount': '150'});
  await client.hMSet('order:5', {'region': 'North', 'amount': '50'});

  await Future<void>.delayed(const Duration(milliseconds: 100));

  // 3. Aggregation (FT.AGGREGATE)
  // Query: Group by 'region', Sum 'amount' -> 'total_revenue',
  // Sort by 'total_revenue' DESC
  print('2. Executing Aggregation...');
  try {
    final aggRes = await client.ftAggregate(
      indexName,
      '*',
      options: [
        'GROUPBY',
        '1',
        '@region',
        'REDUCE',
        'SUM',
        '1',
        '@amount',
        'AS',
        'total_revenue',
        'SORTBY',
        '2',
        '@total_revenue',
        'DESC'
      ],
    );
    print('   Aggregation Results: $aggRes');
  } catch (e) {
    print('   Aggregation skipped or failed: $e');
  }

  // 4. Tag Values (FT.TAGVALS)
  print('3. Getting Distinct Tags...');
  try {
    final tags = await client.ftTagVals(indexName, 'region');
    print('   Regions: $tags');
  } catch (e) {
    print('   TagVals failed: $e');
  }

  // 5. Execution Plan (FT.EXPLAIN)
  print('4. Explaining Query...');
  try {
    final plan = await client.ftExplain(indexName, '@region:{North}');
    print('   Query Plan: $plan');
  } catch (e) {
    print('   Explain failed: $e');
  }

  // Cleanup
  await client.ftDropIndex(indexName, dd: true);
  await client.disconnect();
  print('--- Done ---');
}
