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
  await client.flushAll();

  print('--- ⚙️ Search Management Example ---');

  const indexName = 'idx:products';
  const aliasName = 'idx:active_products';

  // Setup Index
  try {
    await client.ftCreate(indexName, schema: ['title', 'TEXT', 'tags', 'TAG']);
  } catch (_) {}

  // 1. Alias Management (FT.ALIASADD / ALIASDEL)
  print('1. Managing Aliases...');
  try {
    // Create Alias
    await client.ftAliasAdd(aliasName, indexName);
    print('   Alias "$aliasName" created -> pointing to "$indexName"');

    // Search via Alias
    await client.ftSearch(aliasName, '*');
    print('   Search via alias successful.');

    // Delete Alias
    await client.ftAliasDel(aliasName);
    print('   Alias deleted.');
  } catch (e) {
    print('   Alias operations failed: $e');
  }

  // 2. Synonym Management (FT.SYNUPDATE / SYNDUMP)
  print('2. Managing Synonyms...');
  try {
    // Update Synonyms: group "tech" includes "computer", "laptop"
    await client.ftSynUpdate(
      indexName,
      'tech', // group id
      ['computer', 'laptop', 'pc'],
    );

    // Dump Synonyms
    final dump = await client.ftSynDump(indexName);
    print('   Synonym Dump: $dump');
  } catch (e) {
    print('   Synonym operations failed: $e');
  }

  // 3. Dictionary (FT.DICTADD / DICTDUMP)
  print('3. Managing Dictionaries...');
  try {
    await client.ftDictAdd(
      'custom_dict',
      ['foo', 'bar', 'baz'],
    );
    final dictTerms = await client.ftDictDump('custom_dict');
    print('   Dictionary Terms: $dictTerms');

    // Cleanup Dictionary
    await client.ftDictDel('custom_dict', ['foo']);
  } catch (e) {
    print('   Dictionary operations failed: $e');
  }

  // Cleanup
  await client.ftDropIndex(indexName, dd: true);
  await client.disconnect();
  print('--- Done ---');
}
