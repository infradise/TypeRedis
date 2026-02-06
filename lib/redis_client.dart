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

/// This library provides a Redis-compatible interface.
///
/// It allows users to use the client with familiar class names (e.g.,
/// [RedisClient], [RedisException]).
/// This is a wrapper around `typeredis` to provide a seamless developer
/// experience (DX)
/// for those migrating from Redis or preferring Redis terminology.
library;

import 'typeredis.dart';

// --- Clients ---

/// Alias for [TRClient]. Use this for Standalone/Sentinel connections.
typedef RedisClient = TRClient;

/// Alias for [TRClusterClient]. Use this for Cluster connections.
typedef RedisClusterClient = TRClusterClient;

/// Alias for [TRPool]. Use this for connection pooling.
typedef RedisPool = TRPool;

// --- Configuration ---

/// Alias for [TRConnectionSettings].
typedef RedisConnectionSettings = TRConnectionSettings;

/// Alias for [TRLogLevel].
typedef RedisLogLevel = TRLogLevel;

// --- Data Models ---

/// Alias for [TRMessage]. Represents a Pub/Sub message.
typedef RedisMessage = TRMessage;

// --- Exceptions (Crucial for try-catch blocks) ---

/// Alias for [TRException]. The base class for all exceptions.
typedef RedisException = TRException;

/// Alias for [TRConnectionException]. Thrown on network/socket errors.
typedef RedisConnectionException = TRConnectionException;

/// Alias for [TRServerException]. Thrown when the server responds with
/// an error.
typedef RedisServerException = TRServerException;

/// Alias for [TRClientException]. Thrown on invalid API usage.
typedef RedisClientException = TRClientException;

/// Alias for [TRParsingException]. Thrown on protocol parsing errors.
typedef RedisParsingException = TRParsingException;