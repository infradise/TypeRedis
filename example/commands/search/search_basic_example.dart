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
  // 1. Connection Setup
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

  // Clean start: Remove existing data to avoid conflicts
  await client.flushAll();

  print('--- 🔍 Search Basic Example ---');

  const indexName = 'idx:users';

  // 2. Create Index (FT.CREATE)
  // Indexing Hash keys starting with "user:"
  // Schema: name (TEXT), age (NUMERIC)
  print('1. Creating Index: $indexName');
  try {
    await client.ftCreate(
      indexName,
      options: ['ON', 'HASH', 'PREFIX', '1', 'user:'],
      schema: ['name', 'TEXT', 'age', 'NUMERIC'],
    );
  } catch (e) {
    print('Error creating index: $e');
  }

  // 3. Add Data (Standard Redis HSET)
  // RediSearch automatically indexes these because they match the prefix
  // "user:"
  print('2. Adding Data...');
  await client.hMSet('user:101', {'name': 'Alice Wonderland', 'age': '25'});
  await client.hMSet('user:102', {'name': 'Bob Builder', 'age': '30'});
  await client.hMSet('user:103', {'name': 'Charlie Chaplin', 'age': '45'});

  // Give Redis a moment to index the documents
  await Future<void>.delayed(const Duration(milliseconds: 100));

  // 4. Search (FT.SEARCH)
  // A. Text Search: Find users with "Alice" in the name
  print('3. Searching for "Alice"...');
  final searchRes = await client.ftSearch(indexName, 'Alice');
  print('   Result: $searchRes');

  // B. Numeric Filter: Find users where age is between 20 and 35
  print('4. Searching for age 20-35...');
  final rangeRes =
      await client.ftSearch(indexName, '*', // Wildcard query (match all)
          options: ['FILTER', 'age', '20', '35']);
  print('   Result: $rangeRes');

  // 5. Cleanup (FT.DROPINDEX)
  // DD option deletes the actual document hashes as well
  print('5. Dropping Index and Data...');
  await client.ftDropIndex(indexName, dd: true);

  await client.disconnect();
  print('--- Done ---');
}
