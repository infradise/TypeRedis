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

import '../commands.dart' show SearchCommands;

extension FtSearchCommand on SearchCommands {
  /// FT.SEARCH index query [options ...]
  /// FT.SEARCH index query `[NOCONTENT]` `[VERBATIM]` `[NOSTOPWORDS]`
  /// [WITHSCORES] [WITHPAYLOADS] [SORBY ...] [LIMIT ...]
  ///
  /// Searches the index with a textual query.
  ///
  /// - [index]: The name of the index.
  /// - [query]: The text query to search for.
  /// - [options]: Additional search options (NOCONTENT, LIMIT, SORTBY, etc.).
  ///
  /// Supported by both Redis and Valkey.
  Future<dynamic> ftSearch(
    String index,
    String query, {
    List<dynamic> options = const [],
  }) async {
    final cmd = <dynamic>['FT.SEARCH', index, query, ...options];
    return execute(cmd);
  }
}
