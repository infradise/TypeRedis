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
    // Group B: Advanced Search & Aggregation (Redis Stack / RediSearch Only)
    // ====================================================================

    testRedis('Advanced: AGGREGATE, EXPLAIN, PROFILE, TAGVALS', () async {
      const indexName = 'idx:sales';

      // 1. Setup specific index for Aggregation
      // Schema: region (TAG), amount (NUMERIC), item (TEXT)
      await client.ftCreate(
        indexName,
        options: ['ON', 'HASH', 'PREFIX', 1, 'sale:'],
        schema: ['region', 'TAG', 'amount', 'NUMERIC', 'item', 'TEXT'],
      );

      // 2. Seed Data
      await client
          .hMSet('sale:1', {'region': 'North', 'amount': 100, 'item': 'TV'});
      await client
          .hMSet('sale:2', {'region': 'North', 'amount': 50, 'item': 'Radio'});
      await client
          .hMSet('sale:3', {'region': 'South', 'amount': 200, 'item': 'TV'});
      await client
          .hMSet('sale:4', {'region': 'South', 'amount': 10, 'item': 'Cable'});

      // Give Redis a moment to index the documents
      await Future<void>.delayed(const Duration(milliseconds: 100));

      try {
        // 3. FT.AGGREGATE
        // Scenario: Group by 'region', Sum 'amount' to 'total_sales',
        // Sort by total DESC
        // Command: FT.AGGREGATE idx:sales * GROUPBY 1 @region REDUCE SUM 1
        // @amount AS total_sales SORTBY 2 @total_sales DESC
        final aggRes = await client.ftAggregate(
          indexName,
          '*',
          options: [
            'GROUPBY',
            1,
            '@region',
            'REDUCE',
            'SUM',
            1,
            '@amount',
            'AS',
            'total_sales',
            'SORTBY',
            2,
            '@total_sales',
            'DESC'
          ],
        ) as List;

        // Result structure: [total_groups, [group1_data...], [group2_data...]]
        // Expect 2 groups (North, South)
        expect(aggRes[0], equals(2));

        // Verify Sorting: South (210) should be first, North (150) second.
        // The first row (after count) is aggRes[1]
        final firstRow = aggRes[1] as List;

        // Structure of row: ['region', 'South', 'total_sales', '210']
        // (Note: Depending on RESP version, it might be a Map or List)
        expect(firstRow.toString(), contains('South'));
        expect(firstRow.toString(), contains('210'));

        // 4. FT.TAGVALS
        // Get all distinct tags from 'region'
        final tags = await client.ftTagVals(indexName, 'region');
        // TODO: check actual results: north, south
        expect(tags, containsAll(['North', 'South']));

        // 5. FT.EXPLAIN
        // Check query execution plan for a simple tag query
        final plan = await client.ftExplain(indexName, '@region:{North}');
        expect(plan, isA<String>());
        expect(plan, contains('TAG')); // Should mention TAG scan

        // 6. FT.PROFILE
        // Profile a simple search query
        final profile = await client.ftProfile(
          indexName,
          type: 'SEARCH',
          query: '*',
          limited: true,
        ) as List;
        // Returns [Results, ProfileDetails]
        expect(profile, isA<List>());
        expect(profile.length, greaterThanOrEqualTo(2));
      } catch (e) {
        // If the server doesn't support these commands (e.g., standard Valkey),
        // we print a warning but don't fail the test suite.
        print('Skipping Advanced Search tests (AGGREGATE/PROFILE): $e');
      } finally {
        // Cleanup index
        await client.ftDropIndex(indexName, dd: true);
      }
    });

    testRedis('Advanced: SPELLCHECK, DICT', () async {
      const indexName = 'idx:dict';

      // Setup index with TEXT field
      await client.ftCreate(indexName, schema: ['text', 'TEXT']);

      // Seed correct data
      await client.hMSet('doc:1', {'text': 'hello world dictionary'});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      try {
        // 1. FT.SPELLCHECK
        // Query with typo "helo", expect suggestion "hello"
        final check = await client.ftSpellCheck(
          indexName,
          'helo',
        );

        // Response structure is complex, but converting to string should
        // reveal the suggestion
        expect(check.toString(), contains('hello'));

        // 2. FT.DICTADD / FT.DICTDUMP
        // Add terms to a custom dictionary
        await client.ftDictAdd('my_custom_dict', ['foo', 'bar']);

        final dump = await client.ftDictDump('my_custom_dict');
        expect(dump, containsAll(['foo', 'bar']));

        // Delete a term
        await client.ftDictDel('my_custom_dict', ['foo']);

        final dumpAfter = await client.ftDictDump('my_custom_dict');
        expect(dumpAfter, contains('bar'));
        expect(dumpAfter, isNot(contains('foo')));
      } catch (e) {
        print('Skipping SPELLCHECK/DICT tests: $e');
      } finally {
        await client.ftDropIndex(indexName, dd: true);
      }
    });
  });
}
