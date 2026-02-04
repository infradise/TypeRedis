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

/// The base class for all exceptions thrown by the valkey_client package.
class TRException implements Exception {
  final String message;

  TRException(this.message);

  @override
  String toString() => 'TRException: $message';
}

/// Thrown when the client fails to connect to the server (e.g., connection
/// refused)
/// or if an established connection is lost.
/// Corresponds to socket-level or network errors.
class TRConnectionException extends TRException {
  /// The original socket exception (e.g., `SocketException`) or error, if
  /// available.
  final Object? originalException;

  TRConnectionException(super.message, [this.originalException]);

  @override
  String toString() =>
      'TRConnectionException: $message (Original: $originalException)';
}

/// Thrown when the Valkey server returns an error reply
/// (e.g., -ERR, -WRONGPASS).
/// These are errors reported by the server itself, indicating a command
/// could not be processed.
class TRServerException extends TRException {
  /// The error code or type returned by the server (e.g., "ERR", "WRONGPASS",
  /// "EXECABORT").
  final String code;

  TRServerException(super.message) : code = message.split(' ').first;

  @override
  String toString() => 'TRServerException($code): $message';
}

/// Thrown when a command is issued in an invalid client state.
///
/// Examples:
/// * Calling `EXEC` without `MULTI`.
/// * Calling `PUBLISH` while the client is in Pub/Sub mode.
/// * Mixing `SUBSCRIBE` and `PSUBSCRIBE` on the same client.
class TRClientException extends TRException {
  TRClientException(super.message);

  @override
  String toString() => 'TRClientException: $message';
}

/// Thrown if the client cannot parse the server's response.
///
/// This may indicate corrupted data, a bug in the client,
/// or an unsupported RESP (Redis Serialization Protocol) version.
class TRParsingException extends TRException {
  TRParsingException(super.message);

  @override
  String toString() => 'TRParsingException: $message';
}

/// Simple exception to signal an intentionally unimplemented feature.
///
/// Simple, user-facing exception to signal an intentionally unimplemented
/// feature. Prefer this over throwing `UnimplementedError` when callers
/// should be able to catch and handle the condition.
///
/// Throw:
/// ```dart
/// throw const FeatureNotImplementedException('this feature is not ready');
/// ```
///
/// Catch:
/// ```dart
/// } on FeatureNotImplementedException catch (e) {
///   print('Feature not implemented: $e');
/// }
/// ```
class FeatureNotImplementedException implements Exception {
  final String message;
  const FeatureNotImplementedException([this.message = '']);
  @override
  String toString() => message.isEmpty
      ? 'FeatureNotImplementedException'
      : 'FeatureNotImplementedException: $message';
}
