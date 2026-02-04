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

import 'dart:async';
import 'package:typeredis/typeredis.dart';

Future<void> main() async {
  final client = TRClient(host: 'localhost', port: 6379);
  await client.connect();

  const cursor = '0';
  const match = '*';
  const count = 100;

  try {
    final scanResult =
        await client.scan(cursor: cursor, match: match, count: count);
    if (scanResult.keys.isEmpty) {
      print('No keys found.');
    } else {
      print('Found ${scanResult.keys.length} keys.');
      scanResult.keys.forEach(print);
      // print(result.keys);
      // for (var key in result.keys) {
      //   print('- $key');
      // }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await client.close();
  }
}
