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

  print('--- 🚀 JSON.DEBUG Commands Example ---\n');

  const key = 'item:1001';

  // 1. Setup Data
  // Creating a nested JSON object to demonstrate DEPTH and FIELDS
  const data = '{'
      '"name": "Over-ear headphones", '
      '"description": "Active noise-cancelling", '
      '"specs": { '
      '"wireless": true, '
      '"type": "USB-C", '
      '"drivers": [40, 50] '
      '},'
      '"price": 129.99, '
      '"colors": ["navy", "gray"] '
      '}';

  await client.jsonSet(key: key, path: '.', data: data);
  print('1. Data Set Complete.');

  // 2. JSON.DEBUG MEMORY
  // Case A: No path -> Returns total size (int)
  final totalMem = await client.jsonDebugMemory(key: key);
  print('2. Memory (Total): $totalMem bytes (Type: ${totalMem.runtimeType})');

  // Case B: With Path -> Returns size of matches (List<dynamic>)
  // This was the issue! path arguments often result in a List return.
  final specsMem = await client.jsonDebugMemory(key: key, path: r'$.specs');
  print('   Memory (Specs): $specsMem (Type: ${specsMem.runtimeType})');

  // 3. JSON.DEBUG FIELDS
  // Case A: No path -> Returns field count of root (int)
  final fieldsCount = await client.jsonDebugFields(key: key);
  print('3. Fields (Root): $fieldsCount (Type: ${fieldsCount.runtimeType})');

  // Case B: With Path -> Returns field count of specific path (List<dynamic>)
  final specsFields = await client.jsonDebugFields(key: key, path: r'$.specs');
  print('   Fields (Specs): $specsFields (Type: ${specsFields.runtimeType})');

  // 4. JSON.DEBUG DEPTH
  final depth = await client.jsonDebugDepth(key: key);
  print('4. Max Depth: $depth');

  // 5. JSON.DEBUG HELP
  final help = await client.jsonDebugHelp();
  print('5. Help Command First Line: ${help.first}');

  // 6. Dangerous / Long Running Commands
  print('\n--- ⚠️ Dangerous Commands Section ---');
  print('(Check your console for warning messages)');

  // This will trigger the "DANGER, LONG RUNNING..." print statement
  final maxDepthKey = await client.jsonDebugMaxDepthKey();
  print('6. Max Depth Key: $maxDepthKey');

  // This will also trigger the warning
  final maxSizeKey = await client.jsonDebugMaxSizeKey();
  print('7. Max Size Key: $maxSizeKey');

  // Cleanup
  await client.del([key]);
  await client.close(); // disconnect
  print('\n--- Done ---');
}
