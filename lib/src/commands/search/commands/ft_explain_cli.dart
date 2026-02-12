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

extension FtExplainCliCommand on SearchCommands {
  /// FT.EXPLAINCLI index query [DIALECT dialect]
  ///
  /// Returns the execution plan for a complex query in CLI format.
  ///
  /// - [index]: The index name.
  /// - [query]: The query string.
  /// - [dialect]: Optional dialect version.
  /// - [forceRun]: If true, attempts to execute even if connected to Valkey.
  ///
  /// Note: Not currently supported in Valkey.
  Future<dynamic> ftExplainCli(
    String index,
    String query, {
    int? dialect,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('FT.EXPLAINCLI', forceRun: forceRun);
    final cmd = <dynamic>['FT.EXPLAINCLI', index, query];
    if (dialect != null) cmd.addAll(['DIALECT', dialect]);
    return execute(cmd);
  }
}
