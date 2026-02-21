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

extension TsMGetCommand on TimeSeriesCommands {
  /// TS.MGET [LATEST] [WITHLABELS | SELECTED_LABELS label...] FILTER filter...
  ///
  /// Get the last sample matching the specific filter.
  ///
  /// - [filters]: List of filter expressions (e.g., "label=value").
  /// - [latest]: If true, reports the latest possible value.
  /// - [options]: Optional arguments like WITHLABELS.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsMGet(
    List<String> filters, {
    bool latest = false,
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.MGET', forceRun: forceRun);
    final cmd = <dynamic>['TS.MGET'];
    if (latest) cmd.add('LATEST');
    cmd.addAll(options);
    cmd.add('FILTER');
    cmd.addAll(filters);
    return execute(cmd);
  }

  // TODO: Replace with existing one.
  @Deprecated('DO NOT USE. Will be removed in the future.')

  /// TS.MGET [LATEST] [WITHLABELS | SELECTED_LABELS label...] FILTER filter...
  ///
  /// [latest]: Reports the latest possible value.
  /// [withLabels]: Include all labels in the response.
  /// [selectedLabels]: Include only specific labels in the response.
  /// [filters]: List of filter expressions (e.g., 'type=cpu', 'host=server1').
  Future<dynamic> tsMGet2(
    List<String> filters, {
    bool latest = false,
    bool withLabels = false,
    List<String>? selectedLabels,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.MGET', forceRun: forceRun);

    final cmd = <dynamic>['TS.MGET'];

    if (latest) cmd.add('LATEST');

    if (withLabels) {
      cmd.add('WITHLABELS');
    } else if (selectedLabels != null && selectedLabels.isNotEmpty) {
      cmd.addAll(['SELECTED_LABELS', ...selectedLabels]);
    }

    cmd.add('FILTER');
    cmd.addAll(filters);

    return execute(cmd);
  }
}
