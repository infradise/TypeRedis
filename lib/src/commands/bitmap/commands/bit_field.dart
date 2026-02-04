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

import '../commands.dart' show BitmapCommands;

/// Helper class to construct BITFIELD operations
class BitFieldOp {
  final String command;
  final List<String> args;

  BitFieldOp._(this.command, this.args);

  /// GET `<type> <offset>`
  /// Returns the specified bit field.
  factory BitFieldOp.get(String type, dynamic offset) =>
      BitFieldOp._('GET', [type, offset.toString()]);

  /// SET `<type> <offset> <value>`
  /// Set the specified bit field and returns its old value.
  factory BitFieldOp.set(String type, dynamic offset, int value) =>
      BitFieldOp._('SET', [type, offset.toString(), value.toString()]);

  /// INCRBY `<type> <offset> <increment>`
  /// Increments or decrements (if negative) the specified bit field and
  /// returns the new value.
  factory BitFieldOp.incrBy(String type, dynamic offset, int increment) =>
      BitFieldOp._('INCRBY', [type, offset.toString(), increment.toString()]);

  /// OVERFLOW [WRAP|SAT|FAIL]
  /// Changes the overflow behavior for subsequent INCRBY commands.
  factory BitFieldOp.overflow(String behavior) =>
      BitFieldOp._('OVERFLOW', [behavior]);
}

extension BitFieldCommand on BitmapCommands {
  /// BITFIELD key [GET type offset] [SET type offset value]
  /// [INCRBY type offset increment] [OVERFLOW WRAP|SAT|FAIL]
  ///
  /// The command treats a Redis string as a array of bits, and is capable of
  /// addressing specific integer fields
  /// of varying bit widths and arbitrary non (necessary) aligned offset.
  ///
  /// Use [BitFieldOp] to construct operations.
  ///
  /// Complexity: O(N) where N is the number of operations.
  ///
  /// Returns:
  /// - [List<int?>]: A list containing the result of each operation (GET,
  ///   SET, INCRBY).
  ///   OVERFLOW does not return a value (does not add to the list).
  Future<List<int?>> bitField(String key, List<BitFieldOp> operations) async {
    final cmd = <String>['BITFIELD', key];

    for (final op in operations) {
      cmd.add(op.command);
      cmd.addAll(op.args);
    }

    final result = await execute(cmd);

    // BITFIELD returns an array of results for each operation that returns
    // a value.
    if (result is List) {
      return result.map((e) {
        if (e is int) return e;
        if (e == null) return null;
        return int.tryParse(e.toString());
      }).toList();
    }
    return [];
  }
}
