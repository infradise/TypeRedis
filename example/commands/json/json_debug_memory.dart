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

TRLogger logger = TRLogger('JSON Debug Memory Example');

void main() async {
  logger.setEnableTRLog(true);

  final client = TRClient(host: '127.0.0.1', port: 6379);

  try {
    await client.connect();

    if (!await client.isJsonModuleLoaded()) {
      logger.info('Error: JSON module is not loaded on this server.');
      return;
    }

    const key = 'item:1';
    const data = '{'
        '"name":"Over-ear headphones", '
        '"description":"Active noise-cancelling over-ear headphones", '
        '"connection":{"wireless":false,"type":"USB-C"},'
        '"price":129.99,"stock":42,"colors":["navy","gray"],'
        '"max_level":[60,90,150]}';
    // const data = 'abc';

    await client.jsonSet(key: key, path: '.', data: data);

    final showData = await client.jsonGet(key: key);
    logger.info(showData.toString());

    final result1 = await client.jsonDebugMemory(key: key);
    // Redis: 592
    // Valkey: 416
    logger.info(result1.toString());

    final result2 = await client.jsonDebugMemory(key: key, path: r'$[*]');
    // Redis: [40, 64, 144, 16, 8, 48, 24]
    // Valkey: [40, 64, 64, 16, 16, 48, 64]
    logger.info(result2.toString());
  } catch (e) {
    logger.error('Error: $e');
  } finally {
    await client.close();
  }
}
