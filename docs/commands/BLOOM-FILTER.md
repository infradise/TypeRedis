<!--
Copyright 2025-2026 Infradise Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# BLOOM FILTER

| keyscope_client | Redis                                                               | Valkey                                               |
|-----------------|---------------------------------------------------------------------|------------------------------------------------------|
| `bfAdd`         | [BF.ADD](https://redis.io/docs/latest/commands/bf.add/)             | [BF.ADD](https://valkey.io/commands/bf.add/)         |
| `bfCard`        | [BF.CARD](https://redis.io/docs/latest/commands/bf.card/)           | [BF.CARD](https://valkey.io/commands/bf.card/)       |
| `bfExists`      | [BF.EXISTS](https://redis.io/docs/latest/commands/bf.exists/)       | [BF.EXISTS](https://valkey.io/commands/bf.exists/)   |
| `bfInfo`        | [BF.INFO](https://redis.io/docs/latest/commands/bf.info/)           | [BF.INFO](https://valkey.io/commands/bf.info/)       |
| `bfInsert`      | [BF.INSERT](https://redis.io/docs/latest/commands/bf.insert/)       | [BF.INSERT](https://valkey.io/commands/bf.insert/)   |
| `bfLoad`        |                                                                     | [BF.LOAD](https://valkey.io/commands/bf.load/)       |
| `bfLoadChunk`   | [BF.LOADCHUNK](https://redis.io/docs/latest/commands/bf.loadchunk/) |                                                      |
| `bfMAdd`        | [BF.MADD](https://redis.io/docs/latest/commands/bf.madd/)           | [BF.MADD](https://valkey.io/commands/bf.madd/)       |
| `bfMExists`     | [BF.MEXISTS](https://redis.io/docs/latest/commands/bf.mexists/)     | [BF.MEXISTS](https://valkey.io/commands/bf.mexists/) |
| `bfReserve`     | [BF.RESERVE](https://redis.io/docs/latest/commands/bf.reserve/)     | [BF.RESERVE](https://valkey.io/commands/bf.reserve/) |
| `bfScanDump`    | [BF.SCANDUMP](https://redis.io/docs/latest/commands/bf.scandump/)   |                                                      |