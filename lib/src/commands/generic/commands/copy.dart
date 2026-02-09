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

extension CopyCommand on GenericCommands {
  /// COPY source destination [DB destination-db] `[REPLACE]`
  ///
  /// Copy the value stored at the source key to the destination key.
  /// Returns 1 (true) if source was copied, 0 (false) if not.
  Future<bool> copy(
    String source,
    String destination, {
    int? destinationDb,
    bool replace = false,
  }) async {
    final cmd = <String>['COPY', source, destination];
    if (destinationDb != null) {
      cmd.add('DB');
      cmd.add(destinationDb.toString());
    }
    if (replace) {
      cmd.add('REPLACE');
    }
    return (await executeInt(cmd)) == 1;
  }
}
