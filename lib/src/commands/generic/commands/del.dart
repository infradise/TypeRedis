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

import '../commands.dart' show GenericCommands;

extension DelCommand on GenericCommands {
  /// DEL key [key ...]
  ///
  /// Removes the specified keys. A key is ignored if it does not exist.
  ///
  /// Complexity:
  /// O(N) where N is the number of keys that will be removed.
  /// When a key to remove holds a value other than a string, the individual
  /// complexity for this key is O(M) where M is the number of elements in
  /// the list, set, sorted set or hash.
  /// Removing a single key that holds a string value is O(1).
  ///
  /// Returns the number of keys that were removed.
  Future<int> del(List<String> keys) async {
    // Return early for empty input
    if (keys.isEmpty) return 0;

    final cmd = <String>['DEL', ...keys];
    return executeInt(cmd);
  }

  // TODO: WILL BE REMOVED AFTER REDESIGN FOR CLUSTER IN THE FUTURE
  // Future<int> del(List<String> keys) async {
  //   // Return early for empty input
  //   if (keys.isEmpty) return 0;
  //
  //   // Group keys by their mapped node using the current slot map.
  //   // If slot map is stale and returns null for any key, try one refresh attempt.
  //   // If any key cannot be mapped (null), return an empty map as a signal.
  //   Map<ClusterNodeInfo, List<String>> groupByNode() {
  //     final map = <ClusterNodeInfo, List<String>>{};
  //     for (final k in keys) {
  //       final node = _slotMap?.getNodeForKey(k);
  //       // signal to caller that map is incomplete
  //       if (node == null) return {}; // signal incomplete mapping
  //       map.putIfAbsent(node, () => []).add(k);
  //     }
  //     return map;
  //   }
  //
  //   // Try grouping with current topology
  //   var groups = groupByNode();
  //
  //   // If grouping failed, refresh topology once and try again
  //   if (groups.isEmpty) {
  //     // Try refreshing topology once and regroup
  //     await _refreshTopology();
  //     groups = groupByNode();
  //
  //     // If still failed, fall back to per-key deletes using _executeOnKey
  //     if (groups.isEmpty) {
  //       // If still empty, fall back to per-key deletes via _executeOnKey to be safe
  //       final results = await Future.wait<int>(
  //         keys.map((k) => _executeOnKey(k, (client) => client.del([k]))),
  //       );
  //       return results.fold<int>(0, (s, r) => s + r);
  //     }
  //   }
  //
  //   // For each node group, call _executeOnKey with a representative key
  //   // and perform a batched DEL for that node's keys.
  //   final futures = groups.entries.map((entry) {
  //     final nodeKeys = entry.value;
  //     final representativeKey = nodeKeys.first;
  //     return _executeOnKey<int>(
  //       representativeKey,
  //       (client) => client.del(nodeKeys),
  //     );
  //   });
  //
  //   // Wait for all node-level deletes to complete and sum results
  //   final results = await Future.wait<int>(futures);
  //   return results.fold<int>(0, (s, r) => s + r);
  // }
}
