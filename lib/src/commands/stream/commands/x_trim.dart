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

import '../commands.dart' show StreamCommands;

extension XTrimCommand on StreamCommands {
  /// XTRIM key MAXLEN|MINID [=|~] threshold [LIMIT count]
  ///
  /// Trims the stream to a certain number of entries or ID.
  Future<int> xTrim(
    String key, {
    int? maxLen,
    String? minId,
    bool approximate = false, // ~
    int? limit,
  }) async {
    final cmd = <String>['XTRIM', key];

    if (maxLen != null) {
      cmd.add('MAXLEN');
      if (approximate) cmd.add('~');
      cmd.add(maxLen.toString());
    } else if (minId != null) {
      cmd.add('MINID');
      if (approximate) cmd.add('~');
      cmd.add(minId);
    } else {
      throw ArgumentError('Either maxLen or minId must be provided.');
    }

    if (limit != null) {
      cmd.add('LIMIT');
      cmd.add(limit.toString());
    }

    return executeInt(cmd);
  }
}
