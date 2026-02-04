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

import 'package:typeredis/typeredis.dart';

void main() async {
  // -------------------------------------------------------
  // 1-1. Redis/Valkey Standalone (Basic)
  // -------------------------------------------------------
  final client = TRClient(host: 'localhost', port: 6379);
  try {
    await client.connect();
    await client.set('Hello', 'Welcome to TypeRedis');
    print(await client.get('Hello'));
  } catch (e) {
    print('Error: $e');
  } finally {
    await client.close();
  }

  // -------------------------------------------------------
  // 1-2. Redis/Valkey Standalone (Advanced)
  // -------------------------------------------------------
  final settings = TRConnectionSettings(
    host: 'localhost',
    port: 6379,
    // useSsl: false,
    // database: 0,
  );
  final aClient = TRClient.fromSettings(settings);
  try {
    await aClient.connect();
    await aClient.set('Hello', 'Welcome to TypeRedis');
    print(await aClient.get('Hello'));
  } catch (e) {
    print('Error: $e');
  } finally {
    await aClient.close();
  }

  // -------------------------------------------------------
  // 2. Redis/Valkey Sentinel
  // -------------------------------------------------------
  final rSettings = TRConnectionSettings(
      host: 'localhost',
      port: 6379,
      readPreference: ReadPreference.preferReplica);
  final rClient = TRClient.fromSettings(rSettings);
  try {
    await rClient.connect();
    await rClient.set('Hello', 'Welcome to TypeRedis');
    print(await rClient.get('Hello'));
  } catch (e) {
    print('Error: $e');
  } finally {
    await rClient.close();
  }

  // -------------------------------------------------------
  // 3. Redis/Valkey Cluster
  // -------------------------------------------------------
  final nodes = [TRConnectionSettings(host: 'localhost', port: 7001)];
  final sClient = TRClusterClient(nodes);
  try {
    await sClient.connect();
    await sClient.set('Hello', 'Welcome to TypeRedis');
    print(await sClient.get('Hello'));
  } catch (e) {
    print('Error: $e');
  } finally {
    await sClient.close();
  }
}
