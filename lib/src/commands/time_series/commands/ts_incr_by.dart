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

import '../commands.dart' show ServerVersionCheck, TimeSeriesCommands;

extension TsIncrByCommand on TimeSeriesCommands {
  /// TS.INCRBY key value [TIMESTAMP timestamp] [RETENTION retentionPeriod]
  /// [UNCOMPRESSED] [CHUNK_SIZE size] [LABELS field value..]
  ///
  /// Increase the value of the sample.
  ///
  /// - [key]: The key name.
  /// - [value]: The value to increase by.
  /// - [options]: Optional arguments.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsIncrBy(
    String key,
    num value, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.INCRBY', forceRun: forceRun);
    final cmd = <dynamic>['TS.INCRBY', key, value, ...options];
    return execute(cmd);
  }

  // TODO: Replace with existing one.
  @Deprecated('DO NOT USE. Will be removed in the future.')

  /// TS.INCRBY key value [TIMESTAMP timestamp] [RETENTION retentionPeriod]
  /// [UNCOMPRESSED] [CHUNK_SIZE size] [LABELS field value..]
  Future<dynamic> tsIncrBy2(
    String key,
    num value, {
    Object? timestamp,
    int? retention,
    bool uncompressed = false,
    int? chunkSize,
    Map<String, String>? labels,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.INCRBY', forceRun: forceRun);

    final cmd = <dynamic>['TS.INCRBY', key, value];

    if (timestamp != null) cmd.addAll(['TIMESTAMP', timestamp]);
    if (retention != null) cmd.addAll(['RETENTION', retention]);
    if (uncompressed) cmd.add('UNCOMPRESSED');
    if (chunkSize != null) cmd.addAll(['CHUNK_SIZE', chunkSize]);

    if (labels != null && labels.isNotEmpty) {
      cmd.add('LABELS');
      labels.forEach((k, v) => cmd.addAll([k, v]));
    }

    return execute(cmd);
  }
}
