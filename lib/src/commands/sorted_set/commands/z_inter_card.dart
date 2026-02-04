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

import '../commands.dart' show SortedSetCommands;

extension ZInterCardCommand on SortedSetCommands {
  /// ZINTERCARD numkeys key [key ...] [LIMIT limit]
  Future<int> zInterCard(List<String> keys, {int? limit}) async {
    final cmd = <String>['ZINTERCARD', keys.length.toString(), ...keys];
    if (limit != null) {
      cmd.add('LIMIT');
      cmd.add(limit.toString());
    }
    return executeInt(cmd);
  }
}
