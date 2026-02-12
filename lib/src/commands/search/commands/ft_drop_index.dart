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

extension FtDropIndexCommand on SearchCommands {
  /// FT.DROPINDEX index `[DD]`
  ///
  /// Deletes an index.
  ///
  /// - [index]: The name of the index to delete.
  /// - [dd]: If true, deletes the actual document hashes associated with
  ///         the index as well.
  ///
  /// Supported by both Redis and Valkey.
  Future<dynamic> ftDropIndex(String index, {bool dd = false}) async {
    final cmd = <dynamic>['FT.DROPINDEX', index];
    if (dd) cmd.add('DD');
    return execute(cmd);
  }
}
