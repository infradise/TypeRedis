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

import '../commands.dart' show GenericCommands;

extension DumpCommand on GenericCommands {
  /// DUMP key
  ///
  /// Serialize the value stored at key in a Redis-specific format and
  /// return it to the user.
  /// Returns the serialized value (binary), or null if the key does not exist.
  Future<List<int>?> dump(String key) async {
    final cmd = <String>['DUMP', key];
    final result = await execute(cmd);
    if (result == null) return null;
    return (result as List).cast<int>();
  }
}
