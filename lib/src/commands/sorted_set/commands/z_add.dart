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

import '../commands.dart' show SortedSetCommands;

extension ZAddCommand on SortedSetCommands {
  /// ZADD key [NX | XX] [GT | LT] `[CH]` `[INCR]` score member
  /// [score member ...]
  ///
  /// Adds all the specified members with the specified scores to
  /// the sorted set stored at key.
  ///
  /// Options:
  /// - [nx]: Only add new elements. Don't update already existing elements.
  /// - [xx]: Only update elements that already exist. Don't add new elements.
  /// - [gt]: Only update existing elements if the new score is greater than
  /// the current score.
  /// - [lt]: Only update existing elements if the new score is less than
  /// the current score.
  /// - [ch]: Modify the return value from the number of new elements added,
  /// to the total number of elements changed.
  /// - [incr]: When this option is specified ZADD acts like ZINCRBY.
  /// Only one score-element pair can be specified in this mode.
  ///
  /// Input:
  /// - [items]: A map of Member -> Score.
  /// (e.g., {'member1': 10, 'member2': 20})
  Future<dynamic> zAdd(
    String key,
    Map<String, num> items, {
    bool nx = false,
    bool xx = false,
    bool gt = false,
    bool lt = false,
    bool ch = false,
    bool incr = false,
  }) async {
    final cmd = <String>['ZADD', key];
    if (nx) cmd.add('NX');
    if (xx) cmd.add('XX');
    if (gt) cmd.add('GT');
    if (lt) cmd.add('LT');
    if (ch) cmd.add('CH');
    if (incr) cmd.add('INCR');

    items.forEach((member, score) {
      cmd.add(score.toString());
      cmd.add(member);
    });

    return execute(cmd); // Returns int (count) or double (new score if INCR)
  }
}
