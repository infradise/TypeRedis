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

extension FtSpellCheckCommand on SearchCommands {
  /// FT.SPELLCHECK index query [DISTANCE dist] [TERMS ...]
  ///
  /// Performs spell correction on a query.
  ///
  /// - [index]: The index name.
  /// - [query]: The query to spell check.
  /// - [options]: Options like DISTANCE or TERMS INCLUDE/EXCLUDE.
  /// - [forceRun]: If true, attempts to execute even if connected to Valkey.
  ///
  /// Note: Not currently supported in Valkey.
  Future<dynamic> ftSpellCheck(
    String index,
    String query, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('FT.SPELLCHECK', forceRun: forceRun);
    final cmd = <dynamic>['FT.SPELLCHECK', index, query, ...options];
    return execute(cmd);
  }
}
