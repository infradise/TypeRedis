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

import '../commands.dart' show ServerCommands;

/// Helper to get a single config value. Returns null if not found/error.
extension ConfigGetCommand on ServerCommands {
  Future<String?> configGet(String parameter) async {
    try {
      // CONFIG GET returns ['parameter', 'value']
      final result = await execute(['CONFIG', 'GET', parameter]);
      if (result is List && result.length >= 2) {
        return result[1] as String;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
