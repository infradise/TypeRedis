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

import '../commands.dart' show SearchCommands, ServerVersionCheck;

extension FtCursorReadCommand on SearchCommands {
  /// FT.CURSOR READ index cursor_id [COUNT read_size]
  ///
  /// Reads from a cursor.
  ///
  /// - [index]: The index name.
  /// - [cursorId]: The cursor ID.
  /// - [count]: Optional number of results to read.
  /// - [forceRun]: If true, attempts to execute even if connected to Valkey.
  ///
  /// Note: Not currently supported in Valkey.
  Future<dynamic> ftCursorRead(
    String index,
    int cursorId, {
    int? count,
    bool forceRun = false,
  }) async {
    await checkValkeySupportExtended('FT.CURSOR', 'READ', forceRun: forceRun);
    final cmd = <dynamic>['FT.CURSOR', 'READ', index, cursorId];
    if (count != null) cmd.addAll(['COUNT', count]);
    return execute(cmd);
  }
}
