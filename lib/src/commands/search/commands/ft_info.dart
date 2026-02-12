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

import '../commands.dart' show SearchCommands;

extension FtInfoCommand on SearchCommands {
  /// FT.INFO index
  ///
  /// Returns information and statistics on the index.
  ///
  /// - [index]: The name of the index to inspect.
  ///
  /// Returns a `Map<String, dynamic>` containing the index information.
  /// Supported by both Redis and Valkey.
  Future<Map<String, dynamic>> ftInfo(String index) async {
    final cmd = <dynamic>['FT.INFO', index];
    final result = await execute(cmd);

    // Convert List result (Key-Value pairs) to Map
    final map = <String, dynamic>{};
    if (result is List) {
      for (var i = 0; i < result.length; i += 2) {
        map[result[i].toString()] = result[i + 1];
      }
    }
    return map;
  }
}
