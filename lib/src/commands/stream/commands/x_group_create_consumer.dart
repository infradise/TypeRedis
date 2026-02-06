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

extension XGroupCreateConsumerCommand on StreamCommands {
  /// XGROUP CREATECONSUMER key group consumer
  ///
  /// Creates a consumer in the consumer group.
  /// Returns: 1 if created, 0 if already exists.
  Future<int> xGroupCreateConsumer(
      String key, String group, String consumer) async {
    final cmd = <String>['XGROUP', 'CREATECONSUMER', key, group, consumer];
    return executeInt(cmd);
  }
}
