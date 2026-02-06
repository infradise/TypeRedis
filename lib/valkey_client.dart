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

/// This library provides a Valkey-compatible interface.
///
/// It allows users to use the client with familiar class names (e.g.,
/// [ValkeyClient], [ValkeyException]).
/// This is a wrapper around `typeredis` to provide a seamless developer
/// experience (DX)
/// for those migrating from Valkey or preferring Valkey terminology.
library;

import 'typeredis.dart';

// --- Clients ---

/// Alias for [TRClient]. Use this for Standalone/Sentinel connections.
typedef ValkeyClient = TRClient;

/// Alias for [TRClusterClient]. Use this for Cluster connections.
typedef ValkeyClusterClient = TRClusterClient;

/// Alias for [TRPool]. Use this for connection pooling.
typedef ValkeyPool = TRPool;

// --- Configuration ---

/// Alias for [TRConnectionSettings].
typedef ValkeyConnectionSettings = TRConnectionSettings;

/// Alias for [TRLogLevel].
typedef ValkeyLogLevel = TRLogLevel;

// --- Data Models ---

/// Alias for [TRMessage]. Represents a Pub/Sub message.
typedef ValkeyMessage = TRMessage;

// --- Exceptions (Crucial for try-catch blocks) ---

/// Alias for [TRException]. The base class for all exceptions.
typedef ValkeyException = TRException;

/// Alias for [TRConnectionException]. Thrown on network/socket errors.
typedef ValkeyConnectionException = TRConnectionException;

/// Alias for [TRServerException]. Thrown when the server responds with
/// an error.
typedef ValkeyServerException = TRServerException;

/// Alias for [TRClientException]. Thrown on invalid API usage.
typedef ValkeyClientException = TRClientException;

/// Alias for [TRParsingException]. Thrown on protocol parsing errors.
typedef ValkeyParsingException = TRParsingException;