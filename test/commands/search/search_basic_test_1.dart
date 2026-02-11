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
import 'package:test/test.dart';

void main() {
  group('Search Commands', () {
    late KeyscopeClient client;
    var isRedis = false;
    const port = 6379;

    setUpAll(() async {
      final tempClient = KeyscopeClient(host: 'localhost', port: port);
      try {
        await tempClient.connect();
        isRedis = await tempClient.isRedisServer();
      } catch (e) {
        print('Warning: Failed to check server type in setUpAll: $e');
      } finally {
        await tempClient.close();
      }
    });

    // Standard Setup: Connect to local instance and flush database
    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    // Teardown: Clean up and disconnect
    tearDown(() async {
      if (isRedis) {
        try {
          if (client.isConnected) {
            await client.close();
          }
        } catch (_) {}
      }

      try {
        // Drop any indexes created during tests to ensure clean slate
        final indexes = await client.ftList();
        for (final index in indexes) {
          await client.ftDropIndex(index, dd: true);
        }
      } catch (e) {
        // Ignore errors if no indexes exist or module is not loaded
      }
      await client.disconnect();
    });

    void testRedis(String description, Future<void> Function() body) {
      test(description, () async {
        if (!isRedis) {
          markTestSkipped('Skipping: This feature is supported on Redis only.');
          return;
        }
        await body();
      });
    }

    // ====================================================================
    // Group A: Core Commands (Supported by BOTH Redis & Valkey)
    // ====================================================================

    // NOTE:
    // - Redis: All succeeded.
    // - Valkey: Invalid field type for field `name`: Unknown argument `TEXT`

    testRedis('Core: CREATE, SEARCH, DROPINDEX, INFO, LIST', () async {
      const indexName = 'idx:users';

      // 1. FT.CREATE
      // Create an index on Hash keys starting with "user:"
      // Schema: name (TEXT), age (NUMERIC)
      await client.ftCreate(
        indexName,
        options: ['ON', 'HASH', 'PREFIX', 1, 'user:'],
        schema: ['name', 'TEXT', 'WEIGHT', 5.0, 'age', 'NUMERIC'],
      );

      // 2. FT._LIST
      // Verify the index exists in the list
      final indexList = await client.ftList();
      expect(indexList, contains(indexName));

      // 3. FT.INFO
      // Verify we can retrieve index info
      final info = await client.ftInfo(indexName);
      expect(info, isNotEmpty);
      expect(info['index_name'], equals(indexName));

      // 4. Seed Data
      // Add some hash data to be indexed
      await client.hMSet('user:1', {'name': 'Alice Smith', 'age': 30});
      await client.hMSet('user:2', {'name': 'Bob Brown', 'age': 25});
      await client.hMSet('user:3', {'name': 'Charlie Smith', 'age': 35});

      // Give RediSearch a moment to index the documents (usually instant,
      // but strictly safe)
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 5. FT.SEARCH (Simple)
      // Search for "Smith"
      final searchRes = await client.ftSearch(indexName, 'Smith') as List;
      // Format: [count, key1, val1, key2, val2, ...]
      // Expect 2 results (Alice and Charlie) + 1 count header = 3 elements
      // minimum logic
      // Actually, standard RESP search response is [total_results, key,
      // [field, val...], key, ...]
      // Depending on RESP version/client parsing, usually the first element is the count.
      expect(searchRes[0], equals(2)); // Total count
      expect(searchRes[0], greaterThanOrEqualTo(2));

      // 6. FT.SEARCH (Numeric Filter)
      // Search for all users, filter age between 20 and 28
      final numericRes = await client
          .ftSearch(indexName, '*', options: ['FILTER', 'age', 20, 28]
              // options: ['FILTER', 'age', '20', '28']
              ) as List;
      expect(numericRes[0], equals(1)); // Should be Bob (25)

      // 7. FT.DROPINDEX
      // Drop the index and the data (DD)
      await client.ftDropIndex(indexName, dd: true);

      final postDropList = await client.ftList();
      expect(postDropList, isNot(contains(indexName)));

      // Verify data is deleted (DD option)
      final exists = await client.exists(['user:1']);
      expect(exists, equals(0));
    });
  });
}
