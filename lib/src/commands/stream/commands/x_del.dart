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

extension XDelCommand on StreamCommands {
  /// XDEL key id [id ...]
  ///
  /// Removes the specified entries from a stream.
  /// Returns the number of entries actually deleted.
  Future<int> xDel(String key, List<String> ids) async {
    final cmd = <String>['XDEL', key, ...ids];
    return executeInt(cmd);
  }
}
