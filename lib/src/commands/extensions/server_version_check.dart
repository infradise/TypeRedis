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

import '../../../keyscope_cluster_client_base.dart'
    show KeyscopeServerException;
import '../commands.dart';

/// Mapping between Dragonfly versions and corresponding Redis versions
const Map<String, String> dragonflyToRedisMap = {
  '1.36.0': '7.4.0',
  // '1.40.0': '8.0.0',
};

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

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

  /// Internal helper to get the minor version (e.g., "7.2.4" -> 2).
  Future<int> get _minorVersion async {
    try {
      final metadata = await getOrFetchMetadata();
      if (metadata.version.isEmpty) return 0;
      final parts = metadata.version.split('.');
      return parts.length > 1 ? int.parse(parts[1]) : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Internal helper to get the patch version (e.g., "7.2.4" -> 4).
  Future<int> get _patchVersion async {
    try {
      final metadata = await getOrFetchMetadata();
      if (metadata.version.isEmpty) return 0;
      final parts = metadata.version.split('.');
      return parts.length > 2 ? int.parse(parts[2]) : 0;
    } catch (_) {
      return 0;
    }
  }

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

  // TODO: How can we decide whether it is Valkey or Memorystore?
  // Google Memorystore for Valkey 9.0: No distinct things.
  // - redis_version:7.2.4
  // - server_name:valkey
  // - valkey_version:9.0.0
  // Future<bool> get isGoogleMemorystore async => _isGoogleMemorystore;
  //
  // TODO: How can we decide whether it is Redis or Memorystore?
  // Google Memorystore for Redis: equivalent to Valkey?

  Future<String> get _getServerName async =>
      (await getOrFetchMetadata()).serverName.toLowerCase();
  Future<String> get getServerName async => _getServerName;

  // ---------------------------------------------------------------------------
  // Public Version Checkers
  // ---------------------------------------------------------------------------
  // e.g., Redis Open Source 8.0.0

  // Redis Community Edition (Redis CE) was renamed to Redis Open Source with
  // the v8.0 release.

  // See also:
  // - https://redis.io/docs/latest/operate/rs/release-notes/rs-7-4-2-releases/rs-7-4-2-54/
  // - https://github.com/redis/redis
  // - https://redis.io/software/
  // - https://redis.io/docs/latest/develop/clients/
  // - https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/release-notes/
  // - https://redis.io/docs/latest/develop/data-types/bitfields/

  Future<bool> isRedis82OrLater() async =>
      (await _isRedis) &&
      (await _majorVersion) >= 8 &&
      (await _minorVersion) >= 2;

  Future<bool> isRedis80OrLater() async =>
      (await _isRedis) && (await _majorVersion) >= 8;

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
    if (forceRun) return;

    final serverName = await getServerName;

    final isValid =
        await doIntegratedCommandChecker(commandName, subCommandName);

    if (!isValid) {
      final serverType = serverName.capitalize();
      throw KeyscopeServerException('Command $commandName '
          '${subCommandName.isNotEmpty ? subCommandName : ''} '
          'is not supported in your $serverType server. '
          'Pass `forceRun: true` to execute it for development reasons.');
    }
  }

  Future<bool> doIntegratedCommandChecker(
      String commandName, String? subCommandName,
      {bool useThrow = true}) async {
    // 1. Command Registry
    // (Map<Command, Map<System, Version>>)
    //
    final commandRegistry = <String, Map<String, List<int>>>{
      // CONNECTION
      for (var cmd in {
        'AUTH',
        'CLIENT',
        'CLIENT CACHING',
        'CLIENT CAPA',
        'CLIENT GETNAME',
        'CLIENT GETREDIR',
        'CLIENT HELP',
        'CLIENT ID',
        'CLIENT IMPORT-SOURCE',
        'CLIENT INFO',
        'CLIENT KILL',
        'CLIENT LIST',
        'CLIENT NO-EVICT',
        'CLIENT NO-TOUCH',
        'CLIENT PAUSE',
        'CLIENT REPLY',
        'CLIENT SETINFO',
        'CLIENT SETNAME',
        'CLIENT TRACKING',
        'CLIENT TRACKINGINFO',
        'CLIENT UNBLOCK',
        'CLIENT UNPAUSE',
        'ECHO',
        'HELLO',
        'PING',
        'QUIT',
        'RESET',
        'SELECT'
      })
        cmd: {
          'redis': [],
          'valkey': [],
        },

      // T-DIGEST SKETCH
      for (var cmd in {
        'TDIGEST.ADD',
        'TDIGEST.BYRANK',
        'TDIGEST.BYREVRANK',
        'TDIGEST.CDF',
        'TDIGEST.CREATE',
        'TDIGEST.INFO',
        'TDIGEST.MAX',
        'TDIGEST.MERGE',
        'TDIGEST.MIN',
        'TDIGEST.QUANTILE',
        'TDIGEST.RANK',
        'TDIGEST.RESET',
        'TDIGEST.REVRANK',
        'TDIGEST.TRIMMED_MEAN'
      })
        cmd: {
          'redis': [2, 4, 0], // Redis Open Source / Bloom
        },

      // TOP-K SKETCH
      for (var cmd in {
        'TOPK.ADD',
        'TOPK.COUNT',
        'TOPK.INCRBY',
        'TOPK.INFO',
        'TOPK.LIST',
        'TOPK.QUERY',
        'TOPK.RESERVE'
      })
        cmd: {
          'redis': [2, 0, 0], // Redis Open Source / Bloom
        },

      // COUNT-MIN SKETCH
      for (var cmd in {
        'CMS.INCRBY',
        'CMS.INFO',
        'CMS.INITBYDIM',
        'CMS.INITBYPROB',
        'CMS.MERGE',
        'CMS.QUERY',
      })
        cmd: {
          'redis': [2, 0, 0], // Redis Open Source / Bloom
        },

      // BLOOM FILTER
      for (var cmd in {
        'BF.ADD',
        'BF.EXISTS',
        'BF.INFO',
        'BF.INSERT',
        'BF.MADD',
        'BF.MEXISTS',
        'BF.RESERVE',
      })
        cmd: {
          'redis': [1, 0, 0], // Redis Open Source / Bloom
          'valkey': [1, 0, 0], // https://github.com/valkey-io/valkey-bloom
        },
      'BF.CARD': {
        'redis': [2, 4, 4], // Redis Open Source / Bloom
      },

      for (var cmd in {'BF.LOADCHUNK', 'BF.SCANDUMP'}) cmd: {'redis': []},
      'BF.LOAD': {'valkey': []},

      // CUCKOO FILTER
      for (var cmd in {
        'CF.ADD',
        'CF.ADDNX',
        'CF.COUNT',
        'CF.DEL',
        'CF.EXISTS',
        'CF.INFO',
        'CF.INSERT',
        'CF.INSERTNX',
        'CF.LOADCHUNK',
        'CF.MEXISTS',
        'CF.RESERVE',
        'CF.SCANDUMP'
      })
        cmd: {
          'redis': [1, 0, 0]
        }, // Redis Open Source / Bloom

      // VECTOR SET
      for (var cmd in {
        'VADD',
        'VCARD',
        'VDIM',
        'VEMB',
        'VGETATTR',
        'VINFO',
        'VISMEMBER',
        'VLINKS',
        'VRANDMEMBER',
        'VREM',
        'VSETATTR',
        'VSIM'
      })
        cmd: {
          'redis': [8, 0, 0]
        },
      'VRANGE': {
        'redis': [8, 4, 0]
      },

      // SEARCH

      // TODO: RedisSearch? RediSearch? Which one is right?
      // <search> Redis version found by RedisSearch : 8.4.0 - oss
      // <search> RediSearch version 8.4.2 (Git=9e2b676)

      for (var cmd in {
        'FT.ALIASADD',
        'FT.ALIASDEL',
        'FT.ALIASUPDATE',
        'FT.ALTER',
        'FT.TAGVALS',
        'FT.EXPLAIN',
        'FT.EXPLAINCLI',

        // TODO: from/to or since/until
        'FT.CONFIG GET', // Deprecated(Search 8.0.0+). Replaced by CONFIG GET
        'FT.CONFIG SET', // Deprecated(Search 8.0.0+). Replaced by CONFIG SET

        // TODO: separate main and module
      })
        cmd: {
          'redis': [1, 0, 0], // Redis Open Source / Search
        },

      for (var cmd in {
        'FT.CREATE',
        'FT.INFO',
        'FT.SEARCH',
      })
        cmd: {
          'redis': [1, 0, 0], // Redis Open Source / Search
          'valkey': [
            1,
            0,
            0
          ] // Module / https://github.com/valkey-io/valkey-search
        },

      for (var cmd in {
        'FT.AGGREGATE',
        'FT.CURSOR DEL',
        'FT.CURSOR READ',
      })
        cmd: {
          'redis': [1, 1, 0], // Redis Open Source / Search
        },

      for (var cmd in {
        'FT.SYNDUMP',
        'FT.SYNUPDATE',
      })
        cmd: {
          'redis': [1, 2, 0], // Redis Open Source / Search
        },

      for (var cmd in {
        'FT.DICTADD',
        'FT.DICTDEL',
        'FT.DICTDUMP',
        'FT.SPELLCHECK',
      })
        cmd: {
          'redis': [1, 4, 0], // Redis Open Source / Search
        },

      for (var cmd in {
        'FT.DROPINDEX',
        'FT._LIST',
      })
        cmd: {
          'redis': [2, 0, 0], // Redis Open Source / Search
          'valkey': [
            1,
            0,
            0
          ] // Module / https://github.com/valkey-io/valkey-search
        },

      for (var cmd in {
        'FT.PROFILE',
      })
        cmd: {
          'redis': [2, 2, 0], // Redis Open Source / Search
        },

      for (var cmd in {
        'FT.HYBRID',
      })
        cmd: {
          'redis': [8, 4, 0], // Redis Open Source
        },

      // JSON

      'JSON.MERGE': {
        'redis': [2, 6, 0] // Redis Open Source / JSON
      },

      for (var cmd in {'JSON.DEBUG HELP', 'JSON.DEBUG MEMORY'})
        cmd: {
          'redis': [1, 0, 0], // Redis Open Source / JSON
          'valkey': [
            1,
            0,
            0
          ] // Module / https://github.com/valkey-io/valkey-json
        },

      for (var cmd in {
        'JSON.DEBUG DEPTH',
        'JSON.DEBUG FIELDS',
        'JSON.DEBUG KEYTABLE-CHECK',
        'JSON.DEBUG KEYTABLE-CORRUPT',
        'JSON.DEBUG KEYTABLE-DISTRIBUTION',
        'JSON.DEBUG MAX-DEPTH-KEY',
        'JSON.DEBUG MAX-SIZE-KEY',
        'JSON.DEBUG TEST-SHARED-API',
      })
        cmd: {'valkey': []},

      // TIME SERIES

      for (var cmd in {
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
      })
        cmd: {'redis': []},

      // HASH

      'HGETDEL': {
        'redis': [8, 0, 0] // Redis Open Source
      },

      // STRING

      for (var cmd in {'MSET'})
        cmd: {
          'redis': [1, 0, 1], // Redis Open Source
          'valkey': [1, 0, 1]
        },

      for (var cmd in {'DELEX', 'DIGEST', 'MSETEX'})
        cmd: {
          'redis': [8, 4, 0] // Redis Open Source
        },

      'DELIFEQ': {
        'valkey': [9, 0, 0]
      },
    };

    final currentSystem = await getServerName;

    Map<String, List<int>>? targetSpecs;

    if (subCommandName != null) {
      targetSpecs = commandRegistry['$commandName $subCommandName'];
    }
    targetSpecs ??= commandRegistry[commandName];

    if (targetSpecs == null) {
      return false; // Command not found
    }

    final requiredVersion = targetSpecs[currentSystem];

    final fullCommand =
        subCommandName == null ? commandName : '$commandName $subCommandName';

    if (requiredVersion == null) {
      if (useThrow) {
        throw UnsupportedError('Command $fullCommand is not supported on '
            '${currentSystem.capitalize()}.');
      }
      return false;
    }

    Future<bool> checkVersion() async {
      if (requiredVersion.isEmpty) return true;

      final rMajor = requiredVersion[0];
      final rMinor = requiredVersion.length > 1 ? requiredVersion[1] : 0;
      final rPatch = requiredVersion.length > 2 ? requiredVersion[2] : 0;

      if (await _majorVersion < rMajor) return false;
      if (await _majorVersion > rMajor) return true;
      if (await _minorVersion < rMinor) return false;
      if (await _minorVersion > rMinor) return true;
      return await _patchVersion >= rPatch;
    }

    if (!await checkVersion()) {
      if (useThrow) {
        throw UnsupportedError('Unsupported command: $fullCommand. '
            'Requires ${currentSystem.capitalize()} '
            'version ${requiredVersion.join('.')}.');
      }
      return false;
    }

    return true;
  }
}
