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

extension ExpireTimeCommand on GenericCommands {
  /// EXPIRETIME key
  ///
  /// Returns the absolute time at which the key will expire (UNIX timestamp).
  /// Returns -1 if the key exists but has no associated expiration time.
  /// Returns -2 if the key does not exist.
  Future<int> expireTime(String key) async {
    final cmd = <String>['EXPIRETIME', key];
    return executeInt(cmd);
  }
}
