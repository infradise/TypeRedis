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

# SORTED SET

`zadd`, `zrem`, `zrange`

| valkey_client      | Redis                                                                       | Valkey                                                           |
|--------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------|
| `bzMPop`           | [BZMPOP](https://redis.io/docs/latest/commands/bzmpop/)                     | [BZMPOP](https://valkey.io/commands/bzmpop/)                     |
| `bzPopMax`         | [BZPOPMAX](https://redis.io/docs/latest/commands/bzpopmax/)                 | [BZPOPMAX](https://valkey.io/commands/bzpopmax/)                 |
| `bzPopMin`         | [BZPOPMIN](https://redis.io/docs/latest/commands/bzpopmin/)                 | [BZPOPMIN](https://valkey.io/commands/bzpopmin/)                 |
| `zAdd`             | [ZADD](https://redis.io/docs/latest/commands/zadd/)                         | [ZADD](https://valkey.io/commands/zadd/)                         |
| `zCard`            | [ZCARD](https://redis.io/docs/latest/commands/zcard/)                       | [ZCARD](https://valkey.io/commands/zcard/)                       |
| `zCount`           | [ZCOUNT](https://redis.io/docs/latest/commands/zcount/)                     | [ZCOUNT](https://valkey.io/commands/zcount/)                     |
| `zDiff`            | [ZDIFF](https://redis.io/docs/latest/commands/zdiff/)                       | [ZDIFF](https://valkey.io/commands/zdiff/)                       |
| `zDiffStore`       | [ZDIFFSTORE](https://redis.io/docs/latest/commands/zdiffstore/)             | [ZDIFFSTORE](https://valkey.io/commands/zdiffstore/)             |
| `zIncrBy`          | [ZINCRBY](https://redis.io/docs/latest/commands/zincrby/)                   | [ZINCRBY](https://valkey.io/commands/zincrby/)                   |
| `zInter`           | [ZINTER](https://redis.io/docs/latest/commands/zinter/)                     | [ZINTER](https://valkey.io/commands/zinter/)                     |
| `zInterCard`       | [ZINTERCARD](https://redis.io/docs/latest/commands/zintercard/)             | [ZINTERCARD](https://valkey.io/commands/zintercard/)             |
| `zInterStore`      | [ZINTERSTORE](https://redis.io/docs/latest/commands/zinterstore/)           | [ZINTERSTORE](https://valkey.io/commands/zinterstore/)           |
| `zLexCount`        | [ZLEXCOUNT](https://redis.io/docs/latest/commands/zlexcount/)               | [ZLEXCOUNT](https://valkey.io/commands/zlexcount/)               |
| `zMPop`            | [ZMPOP](https://redis.io/docs/latest/commands/zmpop/)                       | [ZMPOP](https://valkey.io/commands/zmpop/)                       |
| `zMScore`          | [ZMSCORE](https://redis.io/docs/latest/commands/zmscore/)                   | [ZMSCORE](https://valkey.io/commands/zmscore/)                   |
| `zPopMax`          | [ZPOPMAX](https://redis.io/docs/latest/commands/zpopmax/)                   | [ZPOPMAX](https://valkey.io/commands/zpopmax/)                   |
| `zPopMin`          | [ZPOPMIN](https://redis.io/docs/latest/commands/zpopmin/)                   | [ZPOPMIN](https://valkey.io/commands/zpopmin/)                   |
| `zRandMember`      | [ZRANDMEMBER](https://redis.io/docs/latest/commands/zrandmember/)           | [ZRANDMEMBER](https://valkey.io/commands/zrandmember/)           |
| `zRange`           | [ZRANGE](https://redis.io/docs/latest/commands/zrange/)                     | [ZRANGE](https://valkey.io/commands/zrange/)                     |
| `zRangeByLex`      | ~~[ZRANGEBYLEX](https://redis.io/docs/latest/commands/zrangebylex/)~~           | [ZRANGEBYLEX](https://valkey.io/commands/zrangebylex/)           |
| `zRangeByScore`    | ~~[ZRANGEBYSCORE](https://redis.io/docs/latest/commands/zrangebyscore/)~~       | [ZRANGEBYSCORE](https://valkey.io/commands/zrangebyscore/)       |
| `zRangeStore`      | [ZRANGESTORE](https://redis.io/docs/latest/commands/zrangestore/)           | [ZRANGESTORE](https://valkey.io/commands/zrangestore/)           |
| `zRank`            | [ZRANK](https://redis.io/docs/latest/commands/zrank/)                       | [ZRANK](https://valkey.io/commands/zrank/)                       |
| `zRem`             | [ZREM](https://redis.io/docs/latest/commands/zrem/)                         | [ZREM](https://valkey.io/commands/zrem/)                         |
| `zRemRangeByLex`   | [ZREMRANGEBYLEX](https://redis.io/docs/latest/commands/zremrangebylex/)     | [ZREMRANGEBYLEX](https://valkey.io/commands/zremrangebylex/)     |
| `zRemRangeByRank`  | [ZREMRANGEBYRANK](https://redis.io/docs/latest/commands/zremrangebyrank/)   | [ZREMRANGEBYRANK](https://valkey.io/commands/zremrangebyrank/)   |
| `zRemRangeByScore` | [ZREMRANGEBYSCORE](https://redis.io/docs/latest/commands/zremrangebyscore/) | [ZREMRANGEBYSCORE](https://valkey.io/commands/zremrangebyscore/) |
| `zRevRange`        | ~~[ZREVRANGE](https://redis.io/docs/latest/commands/zrevrange/)~~               | [ZREVRANGE](https://valkey.io/commands/zrevrange/)               |
| `zRevRangeByLex`   | ~~[ZREVRANGEBYLEX](https://redis.io/docs/latest/commands/zrevrangebylex/)~~     | [ZREVRANGEBYLEX](https://valkey.io/commands/zrevrangebylex/)     |
| `zRevRangeByScore` | ~~[ZREVRANGEBYSCORE](https://redis.io/docs/latest/commands/zrevrangebyscore/)~~ | [ZREVRANGEBYSCORE](https://valkey.io/commands/zrevrangebyscore/) |
| `zRevRank`         | [ZREVRANK](https://redis.io/docs/latest/commands/zrevrank/)                 | [ZREVRANK](https://valkey.io/commands/zrevrank/)                 |
| `zScan`            | [ZSCAN](https://redis.io/docs/latest/commands/zscan/)                       | [ZSCAN](https://valkey.io/commands/zscan/)                       |
| `zScore`           | [ZSCORE](https://redis.io/docs/latest/commands/zscore/)                     | [ZSCORE](https://valkey.io/commands/zscore/)                     |
| `zUnion`           | [ZUNION](https://redis.io/docs/latest/commands/zunion/)                     | [ZUNION](https://valkey.io/commands/zunion/)                     |
| `zUnionStore`      | [ZUNIONSTORE](https://redis.io/docs/latest/commands/zunionstore/)           | [ZUNIONSTORE](https://valkey.io/commands/zunionstore/)           |