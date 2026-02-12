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

extension FtSynUpdateCommand on SearchCommands {
  /// FT.SYNUPDATE index synonym_group_id `[SKIPINITIALSCAN]` term [term ...]
  ///
  /// Updates a synonym group.
  ///
  /// - [index]: The index name.
  /// - [groupId]: The synonym group ID.
  /// - [terms]: List of terms to add.
  /// - [skipInitialScan]: If true, skips the initial scan.
  /// - [forceRun]: If true, attempts to execute even if connected to Valkey.
  ///
  /// Note: Not currently supported in Valkey.
  Future<dynamic> ftSynUpdate(
    String index,
    String groupId,
    List<String> terms, {
    bool skipInitialScan = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('FT.SYNUPDATE', forceRun: forceRun);
    final cmd = <dynamic>['FT.SYNUPDATE', index, groupId];
    if (skipInitialScan) cmd.add('SKIPINITIALSCAN');
    cmd.addAll(terms);
    return execute(cmd);
  }
}
