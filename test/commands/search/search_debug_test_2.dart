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

import 'package:keyscope_client/keyscope_client.dart';
import 'package:keyscope_client/src/utils/module_printer.dart'
    show printPrettyModuleList;
import 'package:test/test.dart';

void main() {
  group('Search Diagnosis', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      // Clean slate: Drop potential existing indexes
      try {
        await client.ftDropIndex('diag:numeric');
        await client.ftDropIndex('diag:text_lower');
        await client.ftDropIndex('diag:tag');
      } catch (_) {}
    });

    tearDown(() async {
      await client.disconnect();
    });

    // 1. Check Server Modules (Identify what is actually running)
    test('Diag 1: Check Modules', () async {
      print('\n--- Diag 1: Checking Modules ---');
      try {
        // Display loaded modules with PrettyTable
        final modules = await client.getModuleList();
        printPrettyModuleList(modules);
      } catch (e) {
        print('Error: Failed to get module list. $e');
      }
    });

    // 2. Try NUMERIC (Test if non-TEXT types work)
    test('Diag 2: Try NUMERIC only', () async {
      print('\n--- Diag 2: Testing NUMERIC Type ---');
      // Verify if schema parsing works for NUMERIC, ruling out TEXT specific
      // issues
      try {
        await client.ftCreate(
          'diag:numeric',
          schema: ['age', 'NUMERIC'],
        );
        print('>>> NUMERIC Success!');
      } catch (e) {
        print('>>> NUMERIC Failed: $e');
        // If this fails, the issue is likely with FT.CREATE syntax itself,
        // not just TEXT type
        rethrow;
      }
    });

    // 3. Try Lowercase 'text' (Case sensitivity check)
    test('Diag 3: Try Lowercase "text"', () async {
      print('\n--- Diag 3: Testing Lowercase "text" ---');
      try {
        await client.ftCreate(
          'diag:text_lower',
          schema: ['title', 'text'], // Sending 'text' in lowercase
        );
        print('>>> Lowercase "text" Success!');
      } catch (e) {
        print('>>> Lowercase "text" Failed: $e');
      }
    });

    // 4. Try TAG (Alternative text-based type)
    test('Diag 4: Try TAG Type', () async {
      print('\n--- Diag 4: Testing TAG Type ---');
      try {
        await client.ftCreate(
          'diag:tag',
          schema: ['tags', 'TAG'],
        );
        print('>>> TAG Success!');
      } catch (e) {
        print('>>> TAG Failed: $e');
      }
    });
  });
}
