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

import '../commands.dart' show BitmapCommands;

extension SetBitCommand on BitmapCommands {
  /// SETBIT key offset value
  ///
  /// Sets or clears the bit at offset in the string value stored at key.
  /// The bit is either set or cleared depending on value, which can be 0 or 1.
  ///
  /// Complexity: O(1)
  ///
  /// Returns:
  /// - [int]: The original bit value stored at the offset.
  Future<int> setBit(String key, int offset, int value) async {
    final cmd = <String>['SETBIT', key, offset.toString(), value.toString()];
    return executeInt(cmd);
  }
}
