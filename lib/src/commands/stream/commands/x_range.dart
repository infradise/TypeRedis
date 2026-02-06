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

extension XRangeCommand on StreamCommands {
  /// XRANGE key start end [COUNT count]
  Future<List<StreamEntry>> xRange(
    String key, {
    String start = '-',
    String end = '+',
    int? count,
  }) async {
    final cmd = <String>['XRANGE', key, start, end];
    if (count != null) {
      cmd.add('COUNT');
      cmd.add(count.toString());
    }

    final result = await execute(cmd);
    if (result == null) return [];

    return (result as List).map((e) => parseStreamEntry(e as List)).toList();
  }
}
