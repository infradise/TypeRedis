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

import '../commands.dart' show StreamCommands, StreamEntry, parseStreamEntry;

extension XReadGroupCommand on StreamCommands {
  /// XREADGROUP GROUP group consumer [COUNT count] [BLOCK milliseconds] [NOACK] STREAMS key [key ...] id [id ...]
  Future<Map<String, List<StreamEntry>>> xReadGroup(
    String group,
    String consumer,
    List<String> keys,
    List<String> ids, {
    int? count,
    int? block,
    bool noAck = false,
  }) async {
    final cmd = <String>['XREADGROUP', 'GROUP', group, consumer];

    if (count != null) {
      cmd.add('COUNT');
      cmd.add(count.toString());
    }
    if (block != null) {
      cmd.add('BLOCK');
      cmd.add(block.toString());
    }
    if (noAck) cmd.add('NOACK');

    cmd.add('STREAMS');
    cmd.addAll(keys);
    cmd.addAll(ids);

    final result = await execute(cmd);

    if (result == null) return {};

    final parsedResult = <String, List<StreamEntry>>{};

    for (final stream in result as List) {
      final streamList = stream as List;
      final key = streamList[0].toString();
      final entriesRaw = streamList[1] as List;

      final entries =
          entriesRaw.map((e) => parseStreamEntry(e as List)).toList();
      parsedResult[key] = entries;
    }

    return parsedResult;
  }
}
