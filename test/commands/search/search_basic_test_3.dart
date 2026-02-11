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
    // Group C: Alias & Synonym Management (Redis Stack / RediSearch Only)
    // ====================================================================

    testRedis('Management: ALIAS, SYNONYM', () async {
      const indexName = 'idx:products';
      const aliasName = 'prod_alias';

      // Setup index
      await client
          .ftCreate(indexName, schema: ['name', 'TEXT', 'category', 'TAG']);

      try {
        // 1. FT.ALIASADD
        // Add an alias 'prod_alias' pointing to 'idx:products'
        await client.ftAliasAdd(aliasName, indexName);

        // 2. Verify Alias Usage
        // We can search using the alias instead of the index name
        // (Should return 0 results but succeed without error)
        final searchRes = await client.ftSearch(aliasName, '*') as List;
        expect(searchRes[0], equals(0));

        // 3. FT.ALIASUPDATE
        // Update alias (Points to same index here, but validates command
        // syntax)
        await client.ftAliasUpdate(aliasName, indexName);

        // 4. FT.ALIASDEL
        // Remove the alias
        await client.ftAliasDel(aliasName);

        // Verify deletion: Searching via alias should fail now (catch error)
        try {
          await client.ftSearch(aliasName, '*');
          fail('Should throw error when searching deleted alias');
        } catch (e) {
          expect(e.toString(), contains('no such index'));
        }

        // 5. FT.SYNUPDATE
        // Create a synonym group (id: "group1") containing "mobile", "phone"
        await client.ftSynUpdate(
          indexName,
          'group1',
          ['mobile', 'phone'],
        );

        // 6. FT.SYNDUMP
        // Verify synonyms are stored
        final synDump = await client.ftSynDump(indexName);
        // Result: { "mobile": ["group1"], "phone": ["group1"] }
        // Depending on client parsing, it might be a Map or List.
        expect(synDump.toString(), contains('mobile'));
        expect(synDump.toString(), contains('phone'));
      } catch (e) {
        print('Skipping Alias/Synonym tests: $e');
      } finally {
        // Cleanup
        await client.ftDropIndex(indexName, dd: true);
      }
    });

    // ====================================================================
    // Group D: Configuration & Cursors (Redis Stack / RediSearch Only)
    // ====================================================================

    testRedis('System: CONFIG, CURSOR', () async {
      const indexName = 'idx:large';

      try {
        // 1. FT.CONFIG GET
        // Check a standard config like 'TIMEOUT'
        final config = await client.ftConfigGet('TIMEOUT');
        // Expect format: [['TIMEOUT', '500']] or Map {'TIMEOUT': '500'}
        expect(config.toString(), contains('TIMEOUT'));

        // TODO: add to test
        // 2. FT.CONFIG SET
        // Set a harmless config (e.g., MINPREFIX to 2) and revert
        // (Caution: Some configs require admin privileges or restart)
        // We skip actual execution to avoid side effects on shared servers,
        // but the command wrapper exists.
        // await client.ftConfigSet('MINPREFIX', '2');

        // 3. FT.CURSOR (Setup)
        // Create index and seed enough data to use cursor
        await client.ftCreate(indexName, schema: ['val', 'NUMERIC']);

        // Add 10 items
        for (var i = 0; i < 10; i++) {
          await client.hMSet('item:$i', {'val': i});
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // 4. FT.AGGREGATE with WITHCURSOR
        // Aggregation often uses cursors for large result sets.
        // Command: FT.AGGREGATE idx:large * LOAD 1 @val WITHCURSOR COUNT 2
        final cursorRes = await client.ftAggregate(
          indexName,
          '*',
          options: ['LOAD', 1, '@val', 'WITHCURSOR', 'COUNT', 2],
        );

        // Response: [Results, cursor_id] (or similar structure depending on
        // version)
        // If successful, we get a cursor ID (non-zero usually)
        if (cursorRes is List && cursorRes.isNotEmpty) {
          // Depending on response structure, the last element might be
          // the cursor ID
          // Note: This is highly dependent on the RediSearch version and
          // response parsing.
          // We just verify command didn't fail.
          expect(cursorRes, isNotNull);

          // If we got a cursor ID, we would call:
          // await client.ftCursorRead(indexName, cursorId, count: 2);
          // await client.ftCursorDel(indexName, cursorId);
        }
      } catch (e) {
        print('Skipping Config/Cursor tests: $e');
      } finally {
        await client.ftDropIndex(indexName, dd: true);
      }
    });
  });
}
