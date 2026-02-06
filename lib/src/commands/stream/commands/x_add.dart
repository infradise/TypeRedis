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

extension XAddCommand on StreamCommands {
  /// XADD key [NOMKSTREAM] [MAXLEN|MINID [=|~] threshold [LIMIT count]] ID
  /// field value [field value ...]
  ///
  /// Appends a new entry to a stream.
  Future<String> xAdd(
    String key,
    Map<String, String> fields, {
    String id = '*',
    int? maxLen,
    bool approximate = false, // '~' if true, '=' if false (default)
    bool noMkStream = false,
  }) async {
    final cmd = <String>['XADD', key];

    if (noMkStream) cmd.add('NOMKSTREAM');

    if (maxLen != null) {
      cmd.add('MAXLEN');
      if (approximate) cmd.add('~');
      cmd.add(maxLen.toString());
    }

    cmd.add(id);

    fields.forEach((k, v) {
      cmd.add(k);
      cmd.add(v);
    });

    return executeString(cmd);
  }
}
