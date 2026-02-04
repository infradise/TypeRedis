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
import 'bit_field.dart' show BitFieldOp;

extension BitFieldRoCommand on BitmapCommands {
  /// BITFIELD_RO key [GET type offset]
  ///
  /// Read-only variant of BITFIELD. It only supports GET operations.
  ///
  /// Complexity: O(N)
  ///
  /// Returns:
  /// - [List<int?>]: A list containing the result of each GET operation.
  Future<List<int?>> bitFieldRo(String key, List<BitFieldOp> operations) async {
    final cmd = <String>['BITFIELD_RO', key];

    for (final op in operations) {
      // BITFIELD_RO only allows GET
      if (op.command != 'GET') {
        throw ArgumentError('BITFIELD_RO only supports GET operations.');
      }
      cmd.add(op.command);
      cmd.addAll(op.args);
    }

    final result = await execute(cmd);

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
