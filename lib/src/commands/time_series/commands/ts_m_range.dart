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

extension TsMRangeCommand on TimeSeriesCommands {
  /// TS.MRANGE fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ...]
  /// [FILTER_BY_VALUE ...] [WITHLABELS] [COUNT count] [ALIGN align]
  /// [AGGREGATION aggregator bucketDuration] [BUCKETTIMESTAMP ...]
  /// `[EMPTY]` FILTER filter...
  ///
  /// Query a range across multiple time series.
  ///
  /// - [fromTimestamp]: Start time.
  /// - [toTimestamp]: End time.
  /// - [filters]: Filter expressions.
  /// - [options]: Additional options.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsMRange(
    Object fromTimestamp,
    Object toTimestamp,
    List<String> filters, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.MRANGE', forceRun: forceRun);
    final cmd = <dynamic>[
      'TS.MRANGE',
      fromTimestamp,
      toTimestamp,
      ...options,
      'FILTER',
      ...filters
    ];
    return execute(cmd);
  }

  // TODO: Replace with existing one.
  @Deprecated('DO NOT USE. Will be removed in the future.')

  /// TS.MRANGE fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ...]
  /// [FILTER_BY_VALUE ...] [WITHLABELS | SELECTED_LABELS label...]
  /// [COUNT count] [ALIGN align] [AGGREGATION aggregator bucketDuration]
  /// [BUCKETTIMESTAMP ...] [EMPTY] [GROUPBY label REDUCE reducer] FILTER
  /// filter...
  Future<dynamic> tsMRange2({
    Object? fromTimestamp,
    Object? toTimestamp,
    List<String> filters = const [],
    bool latest = false,
    List<int>? filterByTs,
    num? filterByValueMin,
    num? filterByValueMax,
    bool withLabels = false,
    List<String>? selectedLabels,
    int? count,
    Object? align,
    String? aggregator,
    int? bucketDuration,
    List<dynamic>? bucketTimestamp,
    bool empty = false,
    String? groupByLabel,
    String? reduceReducer,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.MRANGE', forceRun: forceRun);

    final cmd = <dynamic>['TS.MRANGE', fromTimestamp, toTimestamp];

    if (latest) cmd.add('LATEST');

    if (filterByTs != null && filterByTs.isNotEmpty) {
      cmd.addAll(['FILTER_BY_TS', ...filterByTs]);
    }

    if (filterByValueMin != null && filterByValueMax != null) {
      cmd.addAll(['FILTER_BY_VALUE', filterByValueMin, filterByValueMax]);
    }

    if (withLabels) {
      cmd.add('WITHLABELS');
    } else if (selectedLabels != null && selectedLabels.isNotEmpty) {
      cmd.addAll(['SELECTED_LABELS', ...selectedLabels]);
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

    // Note: GROUPBY requires REDUCE
    if (groupByLabel != null && reduceReducer != null) {
      cmd.addAll(['GROUPBY', groupByLabel, 'REDUCE', reduceReducer]);
    }

    cmd.add('FILTER');
    cmd.addAll(filters);

    return execute(cmd);
  }
}
