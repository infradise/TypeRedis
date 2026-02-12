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

extension FtCreateCommand on SearchCommands {
  /// FT.CREATE index [ON HASH|JSON] [PREFIX count prefix [prefix ...]]
  /// [LANGUAGE default_lang] ... schema
  ///
  /// Creates an index with the given specification.
  ///
  /// - [index]: The name of the index to create.
  /// - [options]: Optional arguments like ON HASH, PREFIX, LANGUAGE, SCORE,
  ///              etc.
  /// - [schema]: The schema definition for the index (e.g., field names and
  ///             types).
  ///
  /// Supported by both Redis and Valkey.
  Future<dynamic> ftCreate(
    String index, {
    List<dynamic> options = const [],
    required List<dynamic> schema,
  }) async {
    final cmd = <dynamic>['FT.CREATE', index, ...options, 'SCHEMA', ...schema];
    return execute(cmd);
  }
}
