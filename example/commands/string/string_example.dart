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

  print('--- 🧵 String Commands Example ---\n');

  // 1. Basic Operations (SET, GET, STRLEN, APPEND)
  await client.set('user:name', 'Alice');
  final name = await client.get('user:name');
  final len = await client.strLen('user:name');
  print('1. Basic: User is $name (Length: $len)');

  await client.append('user:name', ' Smith');
  final fullName = await client.get('user:name');
  print('   Append: Full name is "$fullName"');

  // 2. Multiple Keys (MSET, MGET)
  await client.mSet({'k1': 'v1', 'k2': 'v2', 'k3': 'v3'});
  final mValues = await client.mGet(['k1', 'k2', 'missing']);
  print('2. MGET: $mValues'); // [v1, v2, null]

  // 3. Counters (INCR, DECR, BY, FLOAT)
  await client.set('counter', '10');
  await client.incr('counter'); // 11
  await client.incrBy('counter', 9); // 20
  await client.decr('counter'); // 19
  await client.decrBy('counter', 4); // 15
  final countVal = await client.get('counter');

  await client.set('my_float', '10.50');
  final floatVal = await client.incrByFloat('my_float', 0.1); // 10.6
  print('3. Counters: Int=$countVal, Float=$floatVal');

  // 4. Get and Modify (GETSET, GETDEL)
  // GETSET: Set new value, return old
  final oldVal = await client.getSet('counter', '0');
  print('4. GETSET: Reset counter. Old value was $oldVal');

  // GETDEL: Get value and delete key
  final deletedVal = await client.getDel('counter');
  final exists = await client.get('counter');
  print('   GETDEL: Deleted "$deletedVal". Exists now? $exists');

  // 5. Ranges (SETRANGE, GETRANGE)
  await client.set('msg', 'Hello World');
  // Replace 'World' with 'Dart' (offset 6)
  await client.setRange('msg', 6, 'Dart');
  final newMsg = await client.get('msg');

  // Get substring 'Hello' (0 to 4)
  final sub = await client.getRange('msg', 0, 4);
  print('5. Range: "$newMsg" -> Substring: "$sub"');

  // 6. Expiration & Volatility (SETEX, PSETEX, GETEX)
  // SETEX: Set with 10s TTL
  await client.setEx('temp', 10, 'I will disappear');

  // GETEX: Get and change TTL to 60s
  await client.getEx('temp', ex: 60);
  print('6. Expiration: Key "temp" set with TTL.');

  // 7. Conditional Set (NX, XX)
  // NX: Set only if not exists (Should succeed)
  final setNx1 = await client.setNx('lock', 'holder');
  // NX: Set again (Should fail -> 0)
  final setNx2 = await client.setNx('lock', 'intruder');
  print('7. SETNX: First=$setNx1, Second=$setNx2');

  // SET with options (GET option returns old value)
  await client.set('lock', 'new_holder', xx: true, get: true);

  // 8. Advanced (LCS, DELIFEQ)
  await client.mSet({'s1': 'ohmytext', 's2': 'mynewtext'});

  // Longest Common Subsequence
  final lcsStr = await client.lcs('s1', 's2');
  final lcsLen = await client.lcs('s1', 's2', len: true);
  print('8. LCS: String="$lcsStr", Length=$lcsLen');

  // DELIFEQ (Atomic Delete if Equals)
  await client.set('status', 'processing');
  // Try deleting with wrong value (Fail -> 0)
  final del1 = await client.delIfEq('status', 'done');
  // Try deleting with correct value (Success -> 1)
  final del2 = await client.delIfEq('status', 'processing');
  print('   DELIFEQ: Wrong=$del1, Correct=$del2');

  await client.close(); // disconnect
}
