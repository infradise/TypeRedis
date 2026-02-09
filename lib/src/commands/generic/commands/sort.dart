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

extension SortCommand on GenericCommands {
  /// SORT key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]]
  /// [ASC|DESC] [ALPHA] [STORE destination]
  ///
  /// Sort the elements in a list, set or sorted set.
  /// Returns:
  /// - `List<String>` if STORE is NOT used.
  /// - int (number of elements stored) if STORE IS used.
  Future<dynamic> sort(
    String key, {
    String? by,
    int? limitOffset,
    int? limitCount,
    List<String>? getPatterns,
    bool asc = false, // Default is ASC, but we only send DESC if requested.
    bool desc = false,
    bool alpha = false,
    String? store,
  }) async {
    final cmd = <String>['SORT', key];

    if (by != null) {
      cmd.add('BY');
      cmd.add(by);
    }

    if (limitOffset != null && limitCount != null) {
      cmd.add('LIMIT');
      cmd.add(limitOffset.toString());
      cmd.add(limitCount.toString());
    }

    if (getPatterns != null) {
      for (final pattern in getPatterns) {
        cmd.add('GET');
        cmd.add(pattern);
      }
    }

    if (desc) {
      cmd.add('DESC');
    } else if (asc) {
      cmd.add('ASC'); // Explicit ASC, though default
    }

    if (alpha) cmd.add('ALPHA');

    if (store != null) {
      cmd.add('STORE');
      cmd.add(store);
      // Returns int
      return executeInt(cmd);
    } else {
      // Returns List<String>
      final result = await execute(cmd);
      if (result == null) return <String>[];
      return (result as List).map((e) => e.toString()).toList();
    }
  }
}
