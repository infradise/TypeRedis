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

# SERVER

`flushAll`, `flushDb`, `info`, `infoServerMetadata`

| valkey_client            | Redis                                                                                     | Valkey                                                                         |
|--------------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `acl`                    | [ACL](https://redis.io/docs/latest/commands/acl/)                                         | [ACL](https://valkey.io/commands/acl/)                                         |
| `aclCat`                 | [ACL CAT](https://redis.io/docs/latest/commands/acl-cat/)                                 | [ACL CAT](https://valkey.io/commands/acl-cat/)                                 |
| `aclDelUser`             | [ACL DELUSER](https://redis.io/docs/latest/commands/acl-deluser/)                         | [ACL DELUSER](https://valkey.io/commands/acl-deluser/)                         |
| `aclDryRun`              | [ACL DRYRUN](https://redis.io/docs/latest/commands/acl-dryrun/)                           | [ACL DRYRUN](https://valkey.io/commands/acl-dryrun/)                           |
| `aclGenPass`             | [ACL GENPASS](https://redis.io/docs/latest/commands/acl-genpass/)                         | [ACL GENPASS](https://valkey.io/commands/acl-genpass/)                         |
| `aclGetUser`             | [ACL GETUSER](https://redis.io/docs/latest/commands/acl-getuser/)                         | [ACL GETUSER](https://valkey.io/commands/acl-getuser/)                         |
| `aclHelp`                | [ACL HELP](https://redis.io/docs/latest/commands/acl-help/)                               | [ACL HELP](https://valkey.io/commands/acl-help/)                               |
| `aclList`                | [ACL LIST](https://redis.io/docs/latest/commands/acl-list/)                               | [ACL LIST](https://valkey.io/commands/acl-list/)                               |
| `aclLoad`                | [ACL LOAD](https://redis.io/docs/latest/commands/acl-load/)                               | [ACL LOAD](https://valkey.io/commands/acl-load/)                               |
| `aclLog`                 | [ACL LOG](https://redis.io/docs/latest/commands/acl-log/)                                 | [ACL LOG](https://valkey.io/commands/acl-log/)                                 |
| `aclSave`                | [ACL SAVE](https://redis.io/docs/latest/commands/acl-save/)                               | [ACL SAVE](https://valkey.io/commands/acl-save/)                               |
| `aclSetUser`             | [ACL SETUSER](https://redis.io/docs/latest/commands/acl-setuser/)                         | [ACL SETUSER](https://valkey.io/commands/acl-setuser/)                         |
| `aclUsers`               | [ACL USERS](https://redis.io/docs/latest/commands/acl-users/)                             | [ACL USERS](https://valkey.io/commands/acl-users/)                             |
| `aclWhoAmI`              | [ACL WHOAMI](https://redis.io/docs/latest/commands/acl-whoami/)                           | [ACL WHOAMI](https://valkey.io/commands/acl-whoami/)                           |
| `bgRewriteAof`           | [BGREWRITEAOF](https://redis.io/docs/latest/commands/bgrewriteaof/)                       | [BGREWRITEAOF](https://valkey.io/commands/bgrewriteaof/)                       |
| `bgSave`                 | [BGSAVE](https://redis.io/docs/latest/commands/bgsave/)                                   | [BGSAVE](https://valkey.io/commands/bgsave/)                                   |
| `command`                | [COMMAND](https://redis.io/docs/latest/commands/command/)                                 | [COMMAND](https://valkey.io/commands/command/)                                 |
| `commandCount`           | [COMMAND COUNT](https://redis.io/docs/latest/commands/command-count/)                     | [COMMAND COUNT](https://valkey.io/commands/command-count/)                     |
| `commandDocs`            | [COMMAND DOCS](https://redis.io/docs/latest/commands/command-docs/)                       | [COMMAND DOCS](https://valkey.io/commands/command-docs/)                       |
| `commandGetKeys`         | [COMMAND GETKEYS](https://redis.io/docs/latest/commands/command-getkeys/)                 | [COMMAND GETKEYS](https://valkey.io/commands/command-getkeys/)                 |
| `commandGetKeysAndFlags` | [COMMAND GETKEYSANDFLAGS](https://redis.io/docs/latest/commands/command-getkeysandflags/) | [COMMAND GETKEYSANDFLAGS](https://valkey.io/commands/command-getkeysandflags/) |
| `commandHelp`            | [COMMAND HELP](https://redis.io/docs/latest/commands/command-help/)                       | [COMMAND HELP](https://valkey.io/commands/command-help/)                       |
| `commandInfo`            | [COMMAND INFO](https://redis.io/docs/latest/commands/command-info/)                       | [COMMAND INFO](https://valkey.io/commands/command-info/)                       |
| `commandList`            | [COMMAND LIST](https://redis.io/docs/latest/commands/command-list/)                       | [COMMAND LIST](https://valkey.io/commands/command-list/)                       |
| `commandLog`             | [COMMANDLOG](https://redis.io/docs/latest/commands/commandlog/)                           | [COMMANDLOG](https://valkey.io/commands/commandlog/)                           |
| `commandLogGet`          | [COMMANDLOG GET](https://redis.io/docs/latest/commands/commandlog-get/)                   | [COMMANDLOG GET](https://valkey.io/commands/commandlog-get/)                   |
| `commandLogHelp`         | [COMMANDLOG HELP](https://redis.io/docs/latest/commands/commandlog-help/)                 | [COMMANDLOG HELP](https://valkey.io/commands/commandlog-help/)                 |
| `commandLogLen`          | [COMMANDLOG LEN](https://redis.io/docs/latest/commands/commandlog-len/)                   | [COMMANDLOG LEN](https://valkey.io/commands/commandlog-len/)                   |
| `commandLogReset`        | [COMMANDLOG RESET](https://redis.io/docs/latest/commands/commandlog-reset/)               | [COMMANDLOG RESET](https://valkey.io/commands/commandlog-reset/)               |
| `config`                 | [CONFIG](https://redis.io/docs/latest/commands/config/)                                   | [CONFIG](https://valkey.io/commands/config/)                                   |
| `configGet`              | [CONFIG GET](https://redis.io/docs/latest/commands/config-get/)                           | [CONFIG GET](https://valkey.io/commands/config-get/)                           |
| `configHelp`             | [CONFIG HELP](https://redis.io/docs/latest/commands/config-help/)                         | [CONFIG HELP](https://valkey.io/commands/config-help/)                         |
| `configResetStat`        | [CONFIG RESETSTAT](https://redis.io/docs/latest/commands/config-resetstat/)               | [CONFIG RESETSTAT](https://valkey.io/commands/config-resetstat/)               |
| `configRewrite`          | [CONFIG REWRITE](https://redis.io/docs/latest/commands/config-rewrite/)                   | [CONFIG REWRITE](https://valkey.io/commands/config-rewrite/)                   |
| `configSet`              | [CONFIG SET](https://redis.io/docs/latest/commands/config-set/)                           | [CONFIG SET](https://valkey.io/commands/config-set/)                           |
| `dbSize`                 | [DBSIZE](https://redis.io/docs/latest/commands/dbsize/)                                   | [DBSIZE](https://valkey.io/commands/dbsize/)                                   |
| `debug`                  | [DEBUG](https://redis.io/docs/latest/commands/debug/)                                     | [DEBUG](https://valkey.io/commands/debug/)                                     |
| `failover`               | [FAILOVER](https://redis.io/docs/latest/commands/failover/)                               | [FAILOVER](https://valkey.io/commands/failover/)                               |
| `flushAll`               | [FLUSHALL](https://redis.io/docs/latest/commands/flushall/)                               | [FLUSHALL](https://valkey.io/commands/flushall/)                               |
| `flushDb`                | [FLUSHDB](https://redis.io/docs/latest/commands/flushdb/)                                 | [FLUSHDB](https://valkey.io/commands/flushdb/)                                 |
| `info`                   | [INFO](https://redis.io/docs/latest/commands/info/)                                       | [INFO](https://valkey.io/commands/info/)                                       |
| `infoServerMetadata`     |                                                                                           | |                                                                              |
| `lastSave`               | [LASTSAVE](https://redis.io/docs/latest/commands/lastsave/)                               | [LASTSAVE](https://valkey.io/commands/lastsave/)                               |
| `latency`                | [LATENCY](https://redis.io/docs/latest/commands/latency/)                                 | [LATENCY](https://valkey.io/commands/latency/)                                 |
| `latencyDoctor`          | [LATENCY DOCTOR](https://redis.io/docs/latest/commands/latency-doctor/)                   | [LATENCY DOCTOR](https://valkey.io/commands/latency-doctor/)                   |
| `latencyGraph`           | [LATENCY GRAPH](https://redis.io/docs/latest/commands/latency-graph/)                     | [LATENCY GRAPH](https://valkey.io/commands/latency-graph/)                     |
| `latencyHelp`            | [LATENCY HELP](https://redis.io/docs/latest/commands/latency-help/)                       | [LATENCY HELP](https://valkey.io/commands/latency-help/)                       |
| `latencyHistogram`       | [LATENCY HISTOGRAM](https://redis.io/docs/latest/commands/latency-histogram/)             | [LATENCY HISTOGRAM](https://valkey.io/commands/latency-histogram/)             |
| `latencyHistory`         | [LATENCY HISTORY](https://redis.io/docs/latest/commands/latency-history/)                 | [LATENCY HISTORY](https://valkey.io/commands/latency-history/)                 |
| `latencyLatest`          | [LATENCY LATEST](https://redis.io/docs/latest/commands/latency-latest/)                   | [LATENCY LATEST](https://valkey.io/commands/latency-latest/)                   |
| `latencyReset`           | [LATENCY RESET](https://redis.io/docs/latest/commands/latency-reset/)                     | [LATENCY RESET](https://valkey.io/commands/latency-reset/)                     |
| `lolWut`                 | [LOLWUT](https://redis.io/docs/latest/commands/lolwut/)                                   | [LOLWUT](https://valkey.io/commands/lolwut/)                                   |
| `memory`                 | [MEMORY](https://redis.io/docs/latest/commands/memory/)                                   | [MEMORY](https://valkey.io/commands/memory/)                                   |
| `memoryDoctor`           | [MEMORY DOCTOR](https://redis.io/docs/latest/commands/memory-doctor/)                     | [MEMORY DOCTOR](https://valkey.io/commands/memory-doctor/)                     |
| `memoryHelp`             | [MEMORY HELP](https://redis.io/docs/latest/commands/memory-help/)                         | [MEMORY HELP](https://valkey.io/commands/memory-help/)                         |
| `memoryMallocStats`      | [MEMORY MALLOC-STATS](https://redis.io/docs/latest/commands/memory-malloc-stats/)         | [MEMORY MALLOC-STATS](https://valkey.io/commands/memory-malloc-stats/)         |
| `memoryPurge`            | [MEMORY PURGE](https://redis.io/docs/latest/commands/memory-purge/)                       | [MEMORY PURGE](https://valkey.io/commands/memory-purge/)                       |
| `memoryStats`            | [MEMORY STATS](https://redis.io/docs/latest/commands/memory-stats/)                       | [MEMORY STATS](https://valkey.io/commands/memory-stats/)                       |
| `memoryUsage`            | [MEMORY USAGE](https://redis.io/docs/latest/commands/memory-usage/)                       | [MEMORY USAGE](https://valkey.io/commands/memory-usage/)                       |
| `module`                 | [MODULE](https://redis.io/docs/latest/commands/module/)                                   | [MODULE](https://valkey.io/commands/module/)                                   |
| `moduleHelp`             | [MODULE HELP](https://redis.io/docs/latest/commands/module-help/)                         | [MODULE HELP](https://valkey.io/commands/module-help/)                         |
| `moduleList`             | [MODULE LIST](https://redis.io/docs/latest/commands/module-list/)                         | [MODULE LIST](https://valkey.io/commands/module-list/)                         |
| `moduleLoad`             | [MODULE LOAD](https://redis.io/docs/latest/commands/module-load/)                         | [MODULE LOAD](https://valkey.io/commands/module-load/)                         |
| `moduleLoadEx`           | [MODULE LOADEX](https://redis.io/docs/latest/commands/module-loadex/)                     | [MODULE LOADEX](https://valkey.io/commands/module-loadex/)                     |
| `moduleUnload`           | [MODULE UNLOAD](https://redis.io/docs/latest/commands/module-unload/)                     | [MODULE UNLOAD](https://valkey.io/commands/module-unload/)                     |
| `monitor`                | [MONITOR](https://redis.io/docs/latest/commands/monitor/)                                 | [MONITOR](https://valkey.io/commands/monitor/)                                 |
| `pSync`                  | [PSYNC](https://redis.io/docs/latest/commands/psync/)                                     | [PSYNC](https://valkey.io/commands/psync/)                                     |
| `replConf`               | [REPLCONF](https://redis.io/docs/latest/commands/replconf/)                               | [REPLCONF](https://valkey.io/commands/replconf/)                               |
| `replicaOf`              | [REPLICAOF](https://redis.io/docs/latest/commands/replicaof/)                             | [REPLICAOF](https://valkey.io/commands/replicaof/)                             |
| `restoreAsking`          | [RESTORE-ASKING](https://redis.io/docs/latest/commands/restore-asking/)                   | [RESTORE-ASKING](https://valkey.io/commands/restore-asking/)                   |
| `role`                   | [ROLE](https://redis.io/docs/latest/commands/role/)                                       | [ROLE](https://valkey.io/commands/role/)                                       |
| `save`                   | [SAVE](https://redis.io/docs/latest/commands/save/)                                       | [SAVE](https://valkey.io/commands/save/)                                       |
| `shutdown`               | [SHUTDOWN](https://redis.io/docs/latest/commands/shutdown/)                               | [SHUTDOWN](https://valkey.io/commands/shutdown/)                               |
| `slaveOf`                | [SLAVEOF](https://redis.io/docs/latest/commands/slaveof/)                                 | [SLAVEOF](https://valkey.io/commands/slaveof/)                                 |
| `slowLog`                | [SLOWLOG](https://redis.io/docs/latest/commands/slowlog/)                                 | [SLOWLOG](https://valkey.io/commands/slowlog/)                                 |
| `slowLogGet`             | [SLOWLOG GET](https://redis.io/docs/latest/commands/slowlog-get/)                         | [SLOWLOG GET](https://valkey.io/commands/slowlog-get/)                         |
| `slowLogHelp`            | [SLOWLOG HELP](https://redis.io/docs/latest/commands/slowlog-help/)                       | [SLOWLOG HELP](https://valkey.io/commands/slowlog-help/)                       |
| `slowLogLen`             | [SLOWLOG LEN](https://redis.io/docs/latest/commands/slowlog-len/)                         | [SLOWLOG LEN](https://valkey.io/commands/slowlog-len/)                         |
| `slowLogReset`           | [SLOWLOG RESET](https://redis.io/docs/latest/commands/slowlog-reset/)                     | [SLOWLOG RESET](https://valkey.io/commands/slowlog-reset/)                     |
| `swapDb`                 | [SWAPDB](https://redis.io/docs/latest/commands/swapdb/)                                   | [SWAPDB](https://valkey.io/commands/swapdb/)                                   |
| `sync`                   | [SYNC](https://redis.io/docs/latest/commands/sync/)                                       | [SYNC](https://valkey.io/commands/sync/)                                       |
| `time`                   | [TIME](https://redis.io/docs/latest/commands/time/)                                       | [TIME](https://valkey.io/commands/time/)                                       |