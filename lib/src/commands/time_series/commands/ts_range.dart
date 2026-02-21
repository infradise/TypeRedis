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

extension TsRangeCommand on TimeSeriesCommands {
  /// TS.RANGE key fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ...]
  /// [FILTER_BY_VALUE ...] [COUNT count] [ALIGN align]
  /// [AGGREGATION aggregator bucketDuration] [BUCKETTIMESTAMP ...] `[EMPTY]`
  ///
  /// Query a range in forward direction.
  ///
  /// - [key]: The key name.
  /// - [fromTimestamp]: Start time.
  /// - [toTimestamp]: End time.
  /// - [options]: Additional options (e.g., AGGREGATION, COUNT).
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsRange(
    String key,
    Object fromTimestamp,
    Object toTimestamp, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.RANGE', forceRun: forceRun);
    final cmd = <dynamic>[
      'TS.RANGE',
      key,
      fromTimestamp,
      toTimestamp,
      ...options
    ];
    return execute(cmd);
  }

  // TODO: Replace with existing one.
  @Deprecated('DO NOT USE. Will be removed in the future.')

  /// TS.RANGE key fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ...]
  /// [FILTER_BY_VALUE ...] [COUNT count] [ALIGN align]
  /// [AGGREGATION aggregator bucketDuration] [BUCKETTIMESTAMP ...] `[EMPTY]`
  ///
  /// [latest]: Reports the latest possible value (even if incomplete).
  /// [filterByTs]: List of timestamps to filter by.
  /// [filterByValueMin]: Minimum value to filter.
  /// [filterByValueMax]: Maximum value to filter.
  /// [count]: Limit the number of results.
  /// [align]: Alignment for aggregation ('start', 'end', or specific timestamp)
  /// [aggregator]: Aggregation function (e.g., 'avg', 'sum', 'min', 'max').
  /// [bucketDuration]: Duration of each bucket in milliseconds.
  /// [bucketTimestamp]: Controls how bucket timestamps are reported (e.g., '+',
  ///                    '-', 'mid').
  /// [empty]: If true, reports empty buckets with NaN or similar.
  Future<dynamic> tsRange2(
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
    List<dynamic>? bucketTimestamp, // e.g., ['+', '-']
    bool empty = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.RANGE', forceRun: forceRun);

    final cmd = <dynamic>['TS.RANGE', key, fromTimestamp, toTimestamp];

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
