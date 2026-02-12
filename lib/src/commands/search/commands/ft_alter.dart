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

extension FtAlterCommand on SearchCommands {
  /// FT.ALTER index [options ...] SCHEMA ADD field options ...
  ///
  /// Alters an existing index.
  ///
  /// - [index]: The index name.
  /// - [options]: The alteration options (e.g., SCHEMA ADD ...).
  /// - [forceRun]: If true, attempts to execute even if connected to Valkey.
  ///
  /// Note: Not currently supported in Valkey.
  Future<dynamic> ftAlter(
    String index,
    List<dynamic> options, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('FT.ALTER', forceRun: forceRun);
    final cmd = <dynamic>['FT.ALTER', index, ...options];
    return execute(cmd);
  }
}
