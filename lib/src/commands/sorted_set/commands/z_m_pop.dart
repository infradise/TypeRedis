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

extension ZMPopCommand on SortedSetCommands {
  /// ZMPOP numkeys key [key ...] `<MIN | MAX>` [COUNT count]
  ///
  /// Pops one or more elements with the highest or lowest score from
  /// the first non-empty sorted set key.
  Future<dynamic> zMPop(List<String> keys, String modifier, // MIN or MAX
      {int? count}) async {
    final cmd = <String>['ZMPOP', keys.length.toString(), ...keys, modifier];
    if (count != null) {
      cmd.add('COUNT');
      cmd.add(count.toString());
    }
    return execute(cmd);
  }
}
