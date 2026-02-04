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

import '../commands.dart';

/// Extension to add version checking capabilities to any class using
/// the Commands mixin.
extension ServerVersionCheck on Commands {
  /// Internal helper to get metadata asynchronously.
  /// e.g., the major version (e.g., "7.2.4" -> 7).
  Future<int> get _majorVersion async {
    try {
      final metadata = await getOrFetchMetadata();
      if (metadata.version.isEmpty) return 0;
      // Split "7.2.4" or "7.0.0" and take the first part.
      return int.parse(metadata.version.split('.').first);
    } catch (_) {
      return 0;
    }
  }

  /// Internal helper to check server name.
  Future<bool> get _isRedis async =>
      (await getOrFetchMetadata()).serverName.toLowerCase() == 'redis';
  Future<bool> get _isValkey async =>
      (await getOrFetchMetadata()).serverName.toLowerCase() == 'valkey';

  // ---------------------------------------------------------------------------
  // Public Version Checkers
  // ---------------------------------------------------------------------------

  /// Returns true if the server is Redis and version is 7.0.0 or later.
  Future<bool> isRedis70OrLater() async =>
      (await _isRedis) && (await _majorVersion) >= 7;

  /// Returns true if the server is Valkey and version is 7.0.0 or later.
  Future<bool> isValkey70OrLater() async =>
      (await _isValkey) && (await _majorVersion) >= 7;

  /// Returns true if the server is Valkey and version is 8.0.0 or later.
  Future<bool> isValkey80OrLater() async =>
      (await _isValkey) && (await _majorVersion) >= 8;

  /// Returns true if the server is Valkey and version is
  /// between 7.0.0 (inclusive) and 8.0.0 (exclusive).
  ///
  /// Typically used for features present in 7.x but changed/removed in 8.x.
  ///
  /// Returns true if the server is Valkey and version is in the 7.x range.
  Future<bool> isValkey70To80() async =>
      (await _isValkey) && (await _majorVersion) == 7;
}
