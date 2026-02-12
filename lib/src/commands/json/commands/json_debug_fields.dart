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

import '../commands.dart' show JsonCommands, ServerVersionCheck;

extension JsonDebugFieldsCommand on JsonCommands {
  /// JSON.DEBUG FIELDS `<key>` [path]
  ///
  /// Report number of fields in the JSON element.
  /// - Without [path]: returns int.
  /// - With [path]: returns `List<int>` (because of potential multiple
  /// matches).
  ///
  /// [path] defaults to root if not provided.
  ///
  /// Returns the number of fields.
  Future<dynamic> jsonDebugFields(
      {required String key, String? path, bool forceRun = false}) async {
    await checkValkeySupportExtended('JSON.DEBUG', 'FIELDS',
        forceRun: forceRun);

    final cmd = <String>['JSON.DEBUG', 'FIELDS', key];
    if (path != null) {
      cmd.add(path);
    }
    // Must use 'execute' because it returns List<dynamic> if the path is
    // provided
    return execute(cmd);
  }
}
