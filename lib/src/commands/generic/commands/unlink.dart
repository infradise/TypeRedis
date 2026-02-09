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

extension UnlinkCommand on GenericCommands {
  /// UNLINK key [key ...]
  ///
  /// This command is very similar to DEL: it removes the specified keys.
  /// Just like DEL a key is ignored if it does not exist.
  /// The command performs the actual memory reclaiming in a different thread,
  /// so it is not blocking.
  Future<int> unlink(List<String> keys) async {
    final cmd = <String>['UNLINK', ...keys];
    return executeInt(cmd);
  }
}
