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

import '../commands.dart' show Commands;

export 'extensions.dart';

mixin StreamCommands on Commands {}

/// Helper class to represent a Stream Entry (ID + Fields)
class StreamEntry {
  final String id;
  final Map<String, String> fields;

  StreamEntry({required this.id, required this.fields});

  @override
  String toString() => 'StreamEntry(id: $id, fields: $fields)';
}

/// Helper to parse raw stream response: [id, [k, v, k, v]]
StreamEntry parseStreamEntry(List<dynamic> raw) {
  final id = raw[0].toString();
  final fieldList = raw[1] as List;
  final fields = <String, String>{};

  for (var i = 0; i < fieldList.length; i += 2) {
    fields[fieldList[i].toString()] = fieldList[i + 1].toString();
  }

  return StreamEntry(id: id, fields: fields);
}
