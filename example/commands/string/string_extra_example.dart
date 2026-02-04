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

  // Redis Only Feature
  if (!await client.isRedisServer()) {
    print('⚠️  Skipping: This example requires a Redis server.');
    print('   Current server appears to be Valkey or other compatible server.');
    await client.close(); // disconnect
    return;
  }

  await client.flushAll();

  print('--- 🧵 String Extra Commands Example ---\n');

  // 1. MSETEX
  print('1. Executing MSETEX...');
  // Syntax: numkeys key value ... [EX seconds]
  // Library handles numkeys automatically from map size.
  final mSetResult = await client.mSetEx({
    'session:a': 'data_A',
    'session:b': 'data_B',
  }, ex: 60);

  print('   MSETEX Result: $mSetResult');
  final ttl = await client.ttl('session:a');
  print('   TTL check: ${ttl}s');

  // 2. DIGEST
  print('\n2. Executing DIGEST...');
  await client.set('doc', 'SecretContent');
  final hash = await client.digest('doc');
  print('   Digest: $hash');

  // 3. DELEX (Conditional Delete)
  print('\n3. Executing DELEX...');

  // Case A: IFEQ (Match) -> Should delete
  await client.set('status', 'done');
  final delSuccess = await client.delEx('status', ifEq: 'done');
  print('   DELEX (IFEQ match): $delSuccess (Expected 1)');

  // Case B: IFDEQ (Digest Match)
  await client.set('image', 'binary_data');
  final imgDigest = await client.digest('image');
  if (imgDigest != null) {
    // Delete only if digest matches
    final delDigest = await client.delEx('image', ifDeq: imgDigest);
    print('   DELEX (IFDEQ match): $delDigest (Expected 1)');
  }

  await client.close(); // disconnect
  print('\n--- Done ---');
}
