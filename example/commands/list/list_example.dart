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

  print('--- 🚀 List Commands Example ---\n');

  const key = 'my_list';

  // 1. Cleanup
  await client.del([key]);

  // 2. LPUSH / RPUSH
  // Pushing elements: [C, B, A] -> [C, B, A, D, E]
  await client.lPush(key, ['A', 'B', 'C']); // List: [C, B, A]
  await client.rPush(key, ['D', 'E']); // List: [C, B, A, D, E]

  print('2. Pushed elements.');

  // 3. LRANGE
  // Get all elements
  final allElements = await client.lRange(key, 0, -1);
  print('3. Current List: $allElements'); // [C, B, A, D, E]

  // 4. LPOP / RPOP
  final first = await client.lPop(key);
  final last = await client.rPop(key);
  print('4. Popped Head: $first, Tail: $last');

  // 5. LMOVE (Atomic move)
  // Move element from Head to Tail (Rotation)
  // List before: [B, A, D]
  final moved = await client.lMove(key, key, 'LEFT', 'RIGHT');
  print('5. LMOVE (Rotate): Moved $moved to tail');

  final updatedList = await client.lRange(key, 0, -1);
  print('   List after LMOVE: $updatedList');

  // 6. Blocking Operation (BLPOP)
  // Since the list is not empty, this returns immediately.
  print('6. BLPOP (Blocking Pop)...');
  final blResult = await client.bLPop([key], 1.0); // 1 second timeout
  if (blResult != null) {
    print('   Popped from ${blResult[0]}: ${blResult[1]}');
  } else {
    print('   Timed out.');
  }

  // Cleanup
  await client.del([key]);
  await client.close(); // disconnect
  print('\n--- Done ---');
}
