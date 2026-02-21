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

extension TsRevRangeCommand on TimeSeriesCommands {
  /// TS.REVRANGE key fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ...]
  /// [FILTER_BY_VALUE ...] [COUNT count] [ALIGN align]
  /// [AGGREGATION aggregator bucketDuration] [BUCKETTIMESTAMP ...] `[EMPTY]`
  ///
  /// Query a range in reverse direction.
  ///
  /// - [key]: The key name.
  /// - [fromTimestamp]: Start time.
  /// - [toTimestamp]: End time.
  /// - [options]: Additional options.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsRevRange(
    String key,
    Object fromTimestamp,
    Object toTimestamp, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.REVRANGE', forceRun: forceRun);
    final cmd = <dynamic>[
      'TS.REVRANGE',
      key,
      fromTimestamp,
      toTimestamp,
      ...options
    ];
    return execute(cmd);
  }

  // TODO: Replace with existing one.
  @Deprecated('DO NOT USE. Will be removed in the future.')

  /// TS.REVRANGE key fromTimestamp toTimestamp `[LATEST]` ...
  /// Note: [fromTimestamp] is still Min, [toTimestamp] is still Max.
  Future<dynamic> tsRevRange2(
    String key,
    Object fromTimestamp,
    Object toTimestamp, {
    bool latest = false,
    List<int>? filterByTs,
    num? filterByValueMin,
    num? filterByValueMax,
    int? count,
    Object? align,
    String? aggregator,
    int? bucketDuration,
    List<dynamic>? bucketTimestamp,
    bool empty = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.REVRANGE', forceRun: forceRun);

    final cmd = <dynamic>['TS.REVRANGE', key, fromTimestamp, toTimestamp];

    if (latest) cmd.add('LATEST');
    if (filterByTs != null && filterByTs.isNotEmpty) {
      cmd.addAll(['FILTER_BY_TS', ...filterByTs]);
    }
    if (filterByValueMin != null && filterByValueMax != null) {
      cmd.addAll(['FILTER_BY_VALUE', filterByValueMin, filterByValueMax]);
    }
    if (count != null) cmd.addAll(['COUNT', count]);
    if (align != null) cmd.addAll(['ALIGN', align]);
    if (aggregator != null && bucketDuration != null) {
      cmd.addAll(['AGGREGATION', aggregator, bucketDuration]);
    }
    if (bucketTimestamp != null && bucketTimestamp.isNotEmpty) {
      cmd.addAll(['BUCKETTIMESTAMP', ...bucketTimestamp]);
    }
    if (empty) cmd.add('EMPTY');

    return execute(cmd);
  }
}
