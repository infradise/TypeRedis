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

extension ZPopMaxCommand on SortedSetCommands {
  /// ZPOPMAX key [count]
  ///
  /// Removes and returns up to count members with the highest scores in
  /// the sorted set.
  Future<List<String>> zPopMax(String key, [int? count]) async {
    final cmd = <String>['ZPOPMAX', key];
    if (count != null) cmd.add(count.toString());
    final result = await execute(cmd);
    return (result as List).cast<String>();
  }
}
