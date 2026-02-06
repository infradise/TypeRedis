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

import 'package:test/test.dart';
import 'package:typeredis/typeredis.dart';

void main() {
  group('Stream Extended Commands', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close();
    });

    test('Management: XDEL, XTRIM, XLEN, XSETID', () async {
      const key = 'stream:mgmt';

      // Setup: Add 3 entries
      final id1 = await client.xAdd(key, {'v': '1'});
      final id2 = await client.xAdd(key, {'v': '2'});
      final id3 = await client.xAdd(key, {'v': '3'});

      // 1. XLEN
      expect(await client.xLen(key), equals(3));

      // 2. XDEL (Delete middle one)
      final delCount = await client.xDel(key, [id2]);
      expect(delCount, equals(1));
      expect(await client.xLen(key), equals(2));

      // Verify id1 is still present
      final remaining = await client.xRange(key);
      expect(remaining.map((e) => e.id), contains(id1));

      // 3. XTRIM (Keep only the last 1)
      // MAXLEN 1
      final trimCount = await client.xTrim(key, maxLen: 1);
      // Note: XTRIM returns number of entries deleted (id1 deleted here)
      expect(trimCount, equals(1));
      expect(await client.xLen(key), equals(1));

      // Check remaining is id3
      final range = await client.xRange(key);
      expect(range.first.id, equals(id3));

      // 4. XSETID (Set next ID to be higher)
      // Current is id3. Let's set it to something clearly higher.
      // Assuming id3 is like "1700000000000-0", we create a synthetic
      // higher ID.
      final parts = id3.split('-');
      final nextTs = int.parse(parts[0]) + 1000;
      final newLastId = '$nextTs-0';

      final setRes = await client.xSetId(key, newLastId);
      expect(setRes, equals('OK'));
    });

    test('Retrieval: XREVRANGE, XREAD (Standalone)', () async {
      const key = 'stream:rev';
      final id1 = await client.xAdd(key, {'v': '1'});
      final id2 = await client.xAdd(key, {'v': '2'});
      final id3 = await client.xAdd(key, {'v': '3'});

      // 1. XREVRANGE (Reverse order)
      // end='+' (Max ID), start='-' (Min ID)
      final rev = await client.xRevRange(key, end: '+', start: '-');
      expect(rev.length, equals(3));
      expect(rev[0].id, equals(id3)); // Last added is first
      expect(rev[1].id, equals(id2));
      expect(rev[2].id, equals(id1));

      // 2. XREAD (Non-blocking, explicit ID)
      // Read everything after id2
      final readRes = await client.xRead([key], [id2]);
      expect(readRes.containsKey(key), isTrue);
      expect(readRes[key]!.length, equals(1));
      expect(readRes[key]!.first.id, equals(id3));
    });

    test('Group Management: CREATECONSUMER, DELCONSUMER, DESTROY, SETID, HELP',
        () async {
      const key = 'stream:g_mgmt';
      const group = 'g1';

      await client.xAdd(key, {'v': 'init'}); // mkStream: true
      await client.xGroupCreate(key, group, '0');

      // 1. XGROUP CREATECONSUMER
      final created = await client.xGroupCreateConsumer(key, group, 'c1');
      expect(created, equals(1)); // 1 = created new

      // 2. XGROUP SETID (Rewind to 0)
      final setidRes = await client.xGroupSetId(key, group, '0');
      expect(setidRes, equals('OK'));

      // 3. XGROUP DELCONSUMER
      final deletedPending = await client.xGroupDelConsumer(key, group, 'c1');
      // No pending messages for c1, so returns 0
      expect(deletedPending, equals(0));

      // 4. XGROUP DESTROY
      final destroyed = await client.xGroupDestroy(key, group);
      expect(destroyed, equals(1));

      // 5. XGROUP HELP
      final help = await client.xGroupHelp();
      expect(help, isNotEmpty);
      expect(help[0], contains('XGROUP'));
    });

    test('PEL & Claiming: XPENDING, XCLAIM, XAUTOCLAIM', () async {
      const key = 'stream:claim';
      const group = 'g_claim';
      const consumerA = 'alice';
      const consumerB = 'bob';

      final id1 = await client.xAdd(key, {'v': 'msg1'}); // mkStream: true
      final id2 = await client.xAdd(key, {'v': 'msg2'});

      await client.xGroupCreate(key, group, '0');

      // Consumer A reads id1 but does NOT ACK -> Pending
      await client.xReadGroup(group, consumerA, [key], ['>'], count: 1);

      // 1. XPENDING (Summary)
      final pendingSummary = await client.xPending(key, group) as List;
      // [count, minId, maxId, [[consumer, count]]]
      expect(pendingSummary[0], equals(1)); // Total pending
      expect(pendingSummary[1], equals(id1)); // Min ID

      // 2. XPENDING (Extended)
      final pendingDetails = await client.xPending(key, group,
          start: '-', end: '+', count: 10) as List;
      expect(pendingDetails.length, equals(1));
      // Detail structure: [id, consumer, idle, count]
      final detailRow = pendingDetails[0] as List;
      expect(detailRow[0], equals(id1));
      expect(detailRow[1], equals(consumerA));

      // 3. XCLAIM (Bob claims id1 from Alice)
      // Force claim with 0 idle time requirement for test
      final claimed =
          await client.xClaim(key, group, consumerB, 0, [id1], force: true);
      expect(claimed.length, equals(1));
      expect(claimed[0].id, equals(id1));

      // Verify owner changed to Bob via XPENDING
      final pendingAfter = await client.xPending(key, group,
          start: '-', end: '+', count: 10) as List;
      expect((pendingAfter[0] as List)[1], equals(consumerB));

      // ACK id1 to clear PEL for XAUTOCLAIM test
      // ACK id1 here.
      // Otherwise id1 remains in PEL and XAUTOCLAIM below picks id1 again
      // instead of id2.
      await client.xAck(key, group, [id1]);

      // 4. XAUTOCLAIM
      // Read id2 by Alice, no ACK
      await client.xReadGroup(group, consumerA, [key], ['>'], count: 1);

      // Auto claim id2 for Bob (min idle 0 for test)
      // Since id1 is ACKed, the oldest pending message is now id2.
      final autoClaimRes =
          await client.xAutoClaim(key, group, consumerB, 0, '0-0', count: 1);
      // Returns: [nextStartId, [entries]]
      final claimedEntries = autoClaimRes[1] as List;
      expect(claimedEntries.length, equals(1));
      expect((claimedEntries[0] as StreamEntry).id, equals(id2));
    });

    test('Info & Introspection: XINFO STREAM/GROUPS/CONSUMERS/HELP', () async {
      const key = 'stream:info';
      const group = 'g_info';
      const consumer = 'c_info';

      await client.xAdd(
        key,
        {'data': 'x'},
      ); // mkStream: true
      await client.xGroupCreate(key, group, '0');
      await client.xGroupCreateConsumer(key, group, consumer);

      // 1. XINFO STREAM
      final streamInfo = await client.xInfoStream(key) as List;
      // It returns a flat list of key-values [length, 1, radix-tree-keys, ...]
      // Just check we got data back
      expect(streamInfo, isNotEmpty);
      expect(streamInfo.contains('length'), isTrue);

      // 2. XINFO GROUPS
      final groupsInfo = await client.xInfoGroups(key);
      expect(groupsInfo.length, equals(1));
      final groupRow = groupsInfo[0]
          as List; // It's a list of k-v list or map depending on server version
      // In RESP2/3 standardized clients usually map or flat list.
      // Checking simple existence of group name
      expect(groupRow.toString(), contains(group));

      // 3. XINFO CONSUMERS
      final consumersInfo = await client.xInfoConsumers(key, group);
      expect(consumersInfo.length, equals(1));
      final consumerRow = consumersInfo[0] as List;
      expect(consumerRow.toString(), contains(consumer));

      // 4. XINFO HELP
      final help = await client.xInfoHelp();
      expect(help, isNotEmpty);
      expect(help[0], contains('XINFO'));
    });
  });
}
