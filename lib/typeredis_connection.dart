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

// TODO: Consider new architecture concept such as `TRConnection` later
// after feature completeness about full commands for Redis/Valkey.

/// Manages the physical TCP connection and protocol parsing.
abstract class TRConnection {
  // The actual socket connection
  // Socket? _socket;

  /// Implements the actual sending of data to the server.
  /// This is the concrete implementation that Mixins rely on.
  Future<dynamic> execute(List<String> command) async =>
      // 1. Convert command to RESP format
      // 2. Send bytes to _socket
      // 3. Wait for response
      // 4. Parse RESP response
      // 5. Return result
      'Real Server Response';
}
