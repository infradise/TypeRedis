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

extension TsCreateCommand on TimeSeriesCommands {
  /// TS.CREATE key [RETENTION retentionPeriod] [ENCODING encoding]
  /// [CHUNK_SIZE size] [DUPLICATE_POLICY policy] [LABELS field value..]
  ///
  /// Create a new time series.
  ///
  /// - [key]: The key name.
  /// - [options]: Configuration options.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsCreate(
    String key, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.CREATE', forceRun: forceRun);
    final cmd = <dynamic>['TS.CREATE', key, ...options];
    return execute(cmd);
  }

  // TODO: Replace with existing one.
  @Deprecated('DO NOT USE. Will be removed in the future.')

  /// TS.CREATE key [RETENTION retentionPeriod]
  /// [ENCODING uncompressed|compressed] [CHUNK_SIZE size]
  /// [DUPLICATE_POLICY policy] [LABELS field value..]
  ///
  /// Create a new time series.
  ///
  /// [key]: The key name.
  /// [retention]: Retention period in milliseconds (0 = unlimited).
  /// [encoding]: 'COMPRESSED' or 'UNCOMPRESSED'.
  /// [chunkSize]: Memory chunk size in bytes.
  /// [duplicatePolicy]: Policy for handling duplicate samples (e.g., 'BLOCK',
  ///                    'FIRST', 'LAST', 'MIN', 'MAX').
  /// [labels]: A map of labels to associate with the time series.
  /// [tryAnyway]: Force execution on Valkey.
  Future<dynamic> tsCreate2(
    String key, {
    int? retention,
    String? encoding,
    int? chunkSize,
    String? duplicatePolicy,
    Map<String, String>? labels,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.CREATE', forceRun: forceRun);

    final cmd = <dynamic>['TS.CREATE', key];

    if (retention != null) cmd.addAll(['RETENTION', retention]);
    if (encoding != null) cmd.addAll(['ENCODING', encoding]);
    if (chunkSize != null) cmd.addAll(['CHUNK_SIZE', chunkSize]);
    if (duplicatePolicy != null) {
      cmd.addAll(['DUPLICATE_POLICY', duplicatePolicy]);
    }

    if (labels != null && labels.isNotEmpty) {
      cmd.add('LABELS');
      labels.forEach((k, v) => cmd.addAll([k, v]));
    }

    return execute(cmd);
  }
}
