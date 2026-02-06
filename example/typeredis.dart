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

  // -------------------------------------------------------
  // For Redis users
  //
  final redis = RedisClient(
    host: 'localhost',
    port: 6379,
    // password: '',
    // username: '',
  );
  try {
    await redis.connect();
    await redis.set('Hello', 'Welcome to Redis!');
    print(await redis.get('Hello'));
  } catch (e) {
    print('Error: $e');
  } finally {
    await redis.close();
  }

  // -------------------------------------------------------
  // For Valkey users
  //
  final valkey = ValkeyClient(
    host: 'localhost',
    port: 6379,
    // password: '',
    // username: '',
  );
  try {
    await valkey.connect();
    await valkey.set('Hello', 'Welcome to Valkey!');
    print(await valkey.get('Hello'));
  } catch (e) {
    print('Error: $e');
  } finally {
    await valkey.close();
  }
}
