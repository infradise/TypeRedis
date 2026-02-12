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

extension FtConfigSetCommand on SearchCommands {
  /// FT.CONFIG SET option value
  ///
  /// Sets a configuration option for the search module.
  ///
  /// - [option]: The configuration option name.
  /// - [value]: The value to set.
  /// - [forceRun]: If true, attempts to execute even if connected to Valkey.
  ///
  /// Note: Not currently supported in Valkey.
  Future<dynamic> ftConfigSet(
    String option,
    String value, {
    bool forceRun = false,
  }) async {
    await checkValkeySupportExtended('FT.CONFIG', 'SET', forceRun: forceRun);
    return execute(<dynamic>['FT.CONFIG', 'SET', option, value]);
  }
}
