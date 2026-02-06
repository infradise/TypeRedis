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

  print('--- 🛡 TypeRedis Stream Reliability Example (Recovery) ---\n');

  const key = 'tasks:queue';
  const group = 'workers';

  // 1. Setup: Create Stream & Group
  // Add 3 tasks
  final id1 = await client.xAdd(key, {'task': 'email_1'}); // mkStream: true
  final id2 = await client.xAdd(key, {'task': 'email_2'});
  final id3 = await client.xAdd(key, {'task': 'email_3'});

  await client.xGroupCreate(key, group, '0', mkStream: true);
  print('1. Tasks created: $id1, $id2, $id3');

  // 2. Scenario: Worker A crashes
  print('\n2. Simulation: "Worker A" reads but fails to ACK (Crash)...');
  // Worker A reads 2 messages but crashes before ACKing
  await client.xReadGroup(group, 'worker_A', [key], ['>'], count: 2);

  // Verify via XPENDING (Summary)
  final pendingSummary = await client.xPending(key, group) as List;
  print('   Pending Messages Total: ${pendingSummary[0]}'); // Should be 2
  print('   Oldest Pending ID: ${pendingSummary[1]}');

  // 3. XPENDING (Extended): Inspect details
  print('\n3. "Worker B" inspecting pending list (XPENDING)...');
  // List detailed pending messages (idle time check, etc.)
  final pendingDetails = await client.xPending(key, group,
      start: '-',
      end: '+',
      count: 10,
      consumer: 'worker_A' // Inspect specifically A's failure
      ) as List;

  for (var row in pendingDetails) {
    // row: [id, consumer, idle_ms, delivery_count]
    final r = row as List;
    print('   Found abandoned task: ID=${r[0]}, Idle=${r[2]}ms');
  }

  // 4. XCLAIM: Manual Recovery
  print('\n4. "Worker B" claiming specific task (XCLAIM)...');
  // Bob takes ownership of id1. (Assume min-idle-time 0 for test)
  final claimed = await client.xClaim(
    key, group, 'worker_B',
    0, // min idle time
    [id1], // ID to claim
  );

  print('   Worker B claimed: ${claimed[0].id} -> ${claimed[0].fields}');
  // Bob processes and ACKs
  await client.xAck(key, group, [id1]);
  print('   Worker B processed and ACKed task 1.');

  // 5. XAUTOCLAIM: Automatic Recovery
  print('\n5. "Worker C" using Auto-Claim (XAUTOCLAIM)...');
  // Worker C scans for any pending messages older than 0ms (idle) and claims
  // them.
  // Useful for background "janitor" processes.

  // Returns: [nextStartId, [entries]]
  final autoClaimRes = await client.xAutoClaim(
      key,
      group,
      'worker_C',
      0, // min idle time
      '0-0', // start scanning from beginning
      count: 10);

  final entries = autoClaimRes[1] as List;
  if (entries.isNotEmpty) {
    for (var item in entries) {
      final entry = item as StreamEntry;
      print('   Worker C auto-claimed: ${entry.id} -> ${entry.fields}');

      // Process and ACK
      await client.xAck(key, group, [entry.id]);
      print('   Worker C processed and ACKed task.');
    }
  } else {
    print('   Nothing to auto-claim.');
  }

  // Final Check
  final finalPending = await client.xPending(key, group) as List;
  print('\n   Final Pending Count: ${finalPending[0]} (Should be 0)');

  await client.close();
  print('\n--- Done ---');
}
