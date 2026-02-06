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

  print('--- 🌊 TypeRedis Stream Example (IoT Sensor) ---\n');

  const streamKey = 'sensor:temps';
  const groupName = 'processing_service';
  const consumerName = 'worker_1';

  // 1. XADD: Simulate sending sensor data
  print('1. Producing sensor data...');
  final id1 = await client.xAdd(streamKey, {'temp': '21.5', 'unit': 'C'});
  final id2 = await client.xAdd(streamKey, {'temp': '22.0', 'unit': 'C'});
  final id3 = await client.xAdd(streamKey, {'temp': '21.8', 'unit': 'C'});

  print('   Produced 3 events.');
  print('   - ID 1: $id1');
  print('   - ID 2: $id2');
  print('   - ID 3: $id3');

  // 2. XGROUP: Create a consumer group
  // '$' means start reading only new messages (if stream existed),
  // '0' means read all from beginning.
  // We use '0' to process what we just added.
  print('\n2. Creating Consumer Group...');
  try {
    // [Note] mkStream: true is valid here (XGROUP CREATE)
    await client.xGroupCreate(streamKey, groupName, '0', mkStream: true);
    print('   Group "$groupName" created.');
  } catch (e) {
    print('   Group might already exist: $e');
  }

  // 3. XREADGROUP: Read as a consumer
  print('\n3. Consumer "$consumerName" reading pending messages...');
  final streams = await client.xReadGroup(
    groupName,
    consumerName,
    [streamKey],
    ['>'], // Special ID '>' means "messages never delivered to other consumers"
    count: 2,
  );

  if (streams.containsKey(streamKey)) {
    final entries = streams[streamKey]!;
    for (var entry in entries) {
      print('   [$consumerName] Processing: ID=${entry.id}, '
          'Data=${entry.fields}');

      // 4. XACK: Acknowledge processing
      await client.xAck(streamKey, groupName, [entry.id]);
      print('   -> ACKed ${entry.id}');
    }
  }

  // 5. XRANGE: Inspect history
  print('\n5. Inspecting Stream History (XRANGE)...');
  final history =
      await client.xRange(streamKey, start: '-', end: '+', count: 5);
  for (var entry in history) {
    print('   History: ${entry.id} -> ${entry.fields}');
  }

  await client.close();
  print('\n--- Done ---');
}
