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

import '../commands.dart' show StreamCommands;

extension XInfoConsumersCommand on StreamCommands {
  /// XINFO CONSUMERS key group
  ///
  /// Returns a list of all consumers in a specific group.
  Future<List<dynamic>> xInfoConsumers(String key, String group) async {
    final cmd = <String>['XINFO', 'CONSUMERS', key, group];
    return (await execute(cmd)) as List;
  }
}
