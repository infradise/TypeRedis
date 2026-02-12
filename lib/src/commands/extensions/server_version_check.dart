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

/// Mapping between Dragonfly versions and corresponding Redis versions
const Map<String, String> dragonflyToRedisMap = {
  '1.36.0': '7.4.0',
  // '1.40.0': '8.0.0',
};

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

  // /// Internal helper to get the minor version (e.g., "7.2.4" -> 2).
  // Future<int> get _minorVersion async {
  //   try {
  //     final metadata = await getOrFetchMetadata();
  //     if (metadata.version.isEmpty) return 0;
  //     final parts = metadata.version.split('.');
  //     return parts.length > 1 ? int.parse(parts[1]) : 0;
  //   } catch (_) {
  //     return 0;
  //   }
  // }

  // /// Internal helper to get the patch version (e.g., "7.2.4" -> 4).
  // Future<int> get _patchVersion async {
  //   try {
  //     final metadata = await getOrFetchMetadata();
  //     if (metadata.version.isEmpty) return 0;
  //     final parts = metadata.version.split('.');
  //     return parts.length > 2 ? int.parse(parts[2]) : 0;
  //   } catch (_) {
  //     return 0;
  //   }
  // }

  /// Internal helper to check server name.
  Future<bool> get _isRedis async =>
      (await getOrFetchMetadata()).serverName.toLowerCase() == 'redis';
  Future<bool> get _isValkey async =>
      (await getOrFetchMetadata()).serverName.toLowerCase() == 'valkey';
  Future<bool> get _isDragonfly async =>
      (await getOrFetchMetadata()).serverName.toLowerCase() == 'dragonfly';

  Future<bool> get isRedis async => _isRedis;
  Future<bool> get isValkey async => _isValkey;
  Future<bool> get isDragonfly async => _isDragonfly;

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

  /// Check if Dragonfly version is at least 1.36.0
  ///
  /// Dragonfly df-v1.36.0 includes Redis 7.4.
  ///
  Future<bool> isDragonfly136OrLater() async {
    try {
      // final major = await _majorVersion;
      // final minor = await _minorVersion;
      // final patch = await _patchVersion;

      final metadata = await getOrFetchMetadata();
      // if (metadata.dragonflyVersion.isEmpty) return false;

      if (metadata.version.isEmpty) return false;

      final parts = _parseDragonflyVersion(metadata.version);
      final major = parts.isNotEmpty ? parts[0] : 0;
      final minor = parts.length > 1 ? parts[1] : 0;
      final patch = parts.length > 2 ? parts[2] : 0;

      // Check if Dragonfly >= 1.36.0
      final isAtLeast136 = (major > 1) ||
          (major == 1 && minor > 36) ||
          (major == 1 && minor == 36 && patch >= 0);

      if (isAtLeast136) {
        // If Dragonfly >= 1.36.0, then check Redis >= 7.0
        // * Dragonfly == 1.36.0 corresponds to Redis == 7.4
        return (await _isDragonfly) && (await isRedis70OrLater());
      }

      return false;
    } catch (_) {
      // Return false if any error occurs
      return false;
    }
  }

  /// Parse Dragonfly version string like "df-v1.36.0"
  List<int> _parseDragonflyVersion(String version) {
    // Remove prefix "df-v" if present
    final cleaned = version.replaceFirst('df-v', '');
    final parts = cleaned.split('.');
    return parts.map((p) => int.tryParse(p) ?? 0).toList();
  }

  /// Compare two version strings (major.minor.patch)
  bool _isVersionGreaterOrEqual(String current, String target) {
    final currentParts =
        current.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final targetParts =
        target.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    for (var i = 0; i < 3; i++) {
      if (currentParts[i] > targetParts[i]) return true;
      if (currentParts[i] < targetParts[i]) return false;
    }
    return true; // equal
  }

  /// Check if Dragonfly version is at least a mapped version
  Future<bool> isDragonflyAtLeast(String dfVersion) async {
    try {
      final cleaned = dfVersion.replaceFirst('df-v', '');
      for (final entry in dragonflyToRedisMap.entries) {
        if (_isVersionGreaterOrEqual(cleaned, entry.key)) {
          // If Dragonfly >= mapped version, check Redis accordingly
          return (await _isDragonfly) && (await isRedis70OrLater());
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// {@template checkValkeySupport_doc}
  ///
  /// Helper to check if the command is supported in Valkey.
  ///
  /// The loaded modules
  /// - Redis: redis (bf, timeseries, search, vectorset, ReJSON)
  /// - Valkey: valkey-bundle (ldap, bf, search, json)
  /// - Dragonfly: dragonfly (ReJSON, search)
  ///
  /// Time Series
  /// - Since Time Series commands are typically part of the Redis Stack module,
  /// they are not supported in standard Valkey unless the module is loaded.
  ///
  /// Throws [Exception] if [isValkey] is true and [forceRun] is false.
  ///
  /// [commandName]: The name of the command to check
  /// - Search (e.g., 'FT.AGGREGATE').
  /// - Time Series (e.g., 'TS.ADD')
  /// - JSON (e.g., 'JSON.DEBUG')
  ///
  /// [subCommandName]: (**Extended only**) The name of the subcommand to check
  /// - JSON.DEBUG (e.g., 'KEYTABLE-CHECK')
  ///
  /// [forceRun]: If true, bypasses the check and allows execution.
  /// - Force execution for Valkey/Redis compatibility check.
  ///
  /// {@endtemplate}
  Future<void> checkValkeySupport(String commandName,
          {bool forceRun = false}) async =>
      checkValkeySupportExtended(commandName, '', forceRun: forceRun);

  /// {@macro checkValkeySupport_doc}
  Future<void> checkValkeySupportExtended(
      String commandName, String subCommandName,
      {bool forceRun = false}) async {
    if (await isValkey &&
            await isRedisOnlyCommand(commandName, subCommandName) &&
            !forceRun ||
        await isRedis &&
            await isRedisOnlyCommand(commandName, subCommandName) &&
            !forceRun) {
      throw Exception('Command $commandName is not supported in your server. '
          'Pass `forceRun: true` to execute it for development reason.');
    }
    // NOTE: Here are examples:
    // In Valkey,
    // Error: KeyscopeServerException(ERR): ERR unknown command 'FT.AGGREGATE',
    //        with args beginning with: 'index' ''
  }

  Future<bool> isRedisOnlyCommand(
      String commandName, String? subCommandName) async {
    final searchCommands = [
      'FT.AGGREGATE',
      'FT.ALIASADD',
      'FT.ALIASDEL',
      'FT.ALIASUPDATE',
      'FT.ALTER',
      'FT.CONFIG GET',
      'FT.CONFIG SET',
      // 'FT.CREATE',
      'FT.CURSOR DEL',
      'FT.CURSOR READ',
      'FT.DICTADD',
      'FT.DICTDEL',
      'FT.DICTDUMP',
      // 'FT.DROPINDEX',
      'FT.EXPLAIN',
      'FT.EXPLAINCLI',
      'FT.HYBRID',
      // 'FT.INFO',
      // 'FT._LIST',
      'FT.PROFILE',
      // 'FT.SEARCH',
      'FT.SPELLCHECK',
      'FT.SYNDUMP',
      'FT.SYNUPDATE',
      'FT.TAGVALS'
    ];

    final timeSeriesCommands = [
      'TS.ADD',
      'TS.ALTER',
      'TS.CREATE',
      'TS.CREATERULE',
      'TS.DECRBY',
      'TS.DEL',
      'TS.DELETERULE',
      'TS.GET',
      'TS.INCRBY',
      'TS.INFO',
      'TS.MADD',
      'TS.MGET',
      'TS.MRANGE',
      'TS.MREVRANGE',
      'TS.QUERYINDEX',
      'TS.RANGE',
      'TS.REVRANGE'
    ];

    final hashCommands = [
      'HGETDEL',
    ];
    // const jsonDebugCommand = 'JSON.DEBUG';

    final jsonCommands = [
      'JSON.MERGE',
      // jsonDebugCommand
    ];

    final stringCommands = ['DELEX', 'DIGEST', 'MSETEX'];

    return switch (commandName) {
      _ when searchCommands.contains(commandName) => true,
      _ when timeSeriesCommands.contains(commandName) => true,
      _ when hashCommands.contains(commandName) => true,
      _ when jsonCommands.contains(commandName) => true,
      _ when stringCommands.contains(commandName) => true,
      // _ when jsonCommands.contains(commandName) =>
      //   switch (subCommandName) {
      //     _ when jsonSubCommands.contains(subCommandName) => true,
      //     _ => false,
      //   },
      _ => false,
    };
  }

  /// [commandName]: if provided, check it.
  /// [subCommandName]: if provided, check it with [commandName].
  Future<bool> isValkeyOnlyCommand(
      String commandName, String? subCommandName) async {
    const jsonDebugCommand = 'JSON.DEBUG';

    // final jsonCommands = [
    //   jsonDebugCommand,
    // ];

    final jsonSubCommands = [
      'DEPTH',
      'FIELDS',
      'KEYTABLE-CHECK',
      'KEYTABLE-CORRUPT',
      'KEYTABLE-DISTRIBUTION',
      'MAX-DEPTH-KEY',
      'MAX-SIZE-KEY',
      'TEST-SHARED-API'
    ];

    final stringCommands = [
      'DELIFEQ',
    ];

    return switch (commandName) {
      jsonDebugCommand => switch (subCommandName) {
          _ when jsonSubCommands.contains(subCommandName) => true,
          _ => false,
        },
      _ when stringCommands.contains(commandName) => true,
      // _ when jsonCommands.contains(commandName) =>
      //   switch (subCommandName) {
      //     _ when jsonSubCommands.contains(subCommandName) => true,
      //     _ => false,
      //   },
      _ => false,
    };
  }
}
