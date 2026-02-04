# ⚠️ Renamed to TypeRedis

This package (`valkey_client`) has been renamed to **[TypeRedis](https://pub.dev/packages/TypeRedis)**.
Please update your dependencies to use the new package for future updates and support.

---

<br />
<div align="center">
  <h1>valkey_client ⚡</h1> 
  <p>
    The high-performance, cluster-aware Dart client for Redis and Valkey.<br>
  </p>

  [![pub package](https://img.shields.io/pub/v/valkey_client.svg)](https://pub.dev/packages/valkey_client)

  <p>
    <a href="#supported-commands">Supported Commands</a> •
    <a href="#usage">Usage</a> •
    <a href="#need-help">Need help?</a> •
    <a href="#features">Features</a>
  </p>

</div>

## Supported Commands

### Core Data Types

Basic data structures and generic key operations.

* [STRING](https://github.com/infradise/valkey_client/blob/main/docs/commands/STRING.md) / [HASH](https://github.com/infradise/valkey_client/blob/main/docs/commands/HASH.md) / [LIST](https://github.com/infradise/valkey_client/blob/main/docs/commands/LIST.md) / [SET](https://github.com/infradise/valkey_client/blob/main/docs/commands/SET.md) / [SORTED SET](https://github.com/infradise/valkey_client/blob/main/docs/commands/SORTED-SET.md)
* [BITMAP](https://github.com/infradise/valkey_client/blob/main/docs/commands/BITMAP.md) / [HYPERLOGLOG](https://github.com/infradise/valkey_client/blob/main/docs/commands/HYPERLOGLOG.md) / [GEOSPATIAL INDICES](https://github.com/infradise/valkey_client/blob/main/docs/commands/GEOSPATIAL-INDICES.md) / [STREAM](https://github.com/infradise/valkey_client/blob/main/docs/commands/STREAM.md)
* [GENERIC](https://github.com/infradise/valkey_client/blob/main/docs/commands/GENERIC.md) (Keys, Expiration, etc.)

### Modules & Extensions

Advanced data types and query engines (JSON, Search, Probabilistic structures).

* [JSON](https://github.com/infradise/valkey_client/blob/main/docs/commands/JSON.md) / [SEARCH](https://github.com/infradise/valkey_client/blob/main/docs/commands/SEARCH.md) / [TIME SERIES](https://github.com/infradise/valkey_client/blob/main/docs/commands/TIME-SERIES.md) / [VECTOR SET](https://github.com/infradise/valkey_client/blob/main/docs/commands/VECTOR-SET.md)
* [BLOOM FILTER](https://github.com/infradise/valkey_client/blob/main/docs/commands/BLOOM-FILTER.md) / [CUCKOO FILTER](https://github.com/infradise/valkey_client/blob/main/docs/commands/CUCKOO-FILTER.md)
* [COUNT-MIN SKETCH](https://github.com/infradise/valkey_client/blob/main/docs/commands/COUNT-MIN-SKETCH.md) / [T-DIGEST SKETCH](https://github.com/infradise/valkey_client/blob/main/docs/commands/T-DIGEST-SKETCH.md) / [TOP-K SKETCH](https://github.com/infradise/valkey_client/blob/main/docs/commands/TOP-K-SKETCH.md)

### System & Operations

Server management, connection handling, and flow control.

* [CONNECTION](https://github.com/infradise/valkey_client/blob/main/docs/commands/CONNECTION.md) / [SERVER](https://github.com/infradise/valkey_client/blob/main/docs/commands/SERVER.md) / [CLUSTER](https://github.com/infradise/valkey_client/blob/main/docs/commands/CLUSTER.md)
* [PUBSUB](https://github.com/infradise/valkey_client/blob/main/docs/commands/PUBSUB.md) / [TRANSACTIONS](https://github.com/infradise/valkey_client/blob/main/docs/commands/TRANSACTIONS.md) / [SCRIPTING AND FUNCTIONS](https://github.com/infradise/valkey_client/blob/main/docs/commands/SCRIPTING-AND-FUNCTIONS.md)

## Usage

Refer to the [Wiki](https://github.com/infradise/valkey_client/wiki) page in our GitHub repository to see more examples.

### 1\. Example for Standalone or Sentinel environment 

<table>
<tr>
<td>

**`For Redis users`**

```dart
import 'package:valkey_client/redis_client.dart';

void main() async {
  final client = RedisClient();
  try {
    await client.connect(
      host: '127.0.0.1',
      port: 6379
    );
    await client.set('key', 'value');
    print(await client.get('key'));

  } catch (e) {
    print('❌ Failed: $e');
  } finally {
    await client.close();
  }
}
```

</td>
<td>

**`For Valkey users`**

```dart
import 'package:valkey_client/valkey_client.dart';

void main() async {
  final client = ValkeyClient();
  try {
    await client.connect(
      host: '127.0.0.1',
      port: 6379
    );
    await client.set('key', 'value');
    print(await client.get('key'));

  } catch (e) {
    print('❌ Failed: $e');
  } finally {
    await client.close();
  }
}
```

</td>
</tr>
</table>


### 2\. Example for Cluster environment

<table>
<tr>
<td>

**`For Redis users`**

```dart
import 'package:valkey_client/redis_client.dart';

void main() async {

  final nodes = [
    RedisConnectionSettings(
      host: '127.0.0.1',
      port: 7001,
    ),
  ];

  final client = RedisClusterClient(nodes);
  try {
    await client.connect();
    
    await client.set('key', 'value');
    print(await client.get('key'));

  } catch (e) {
    print('❌ Failed: $e');
  } finally {
    await client.close();
  }
}
```

</td>
<td>

**`For Valkey users`**

```dart
import 'package:valkey_client/valkey_client.dart';

void main() async {

  final nodes = [
    ValkeyConnectionSettings(
      host: '127.0.0.1',
      port: 7001,
    ),
  ];

  final client = ValkeyClusterClient(nodes);
  try {
    await client.connect();

    await client.set('key', 'value');
    print(await client.get('key'));

  } catch (e) {
    print('❌ Failed: $e');
  } finally {
    await client.close();
  }
}
```

</td>
</tr>
</table>

## Need help?

1. Still using Redis instead of Valkey? Check out [Developer Experience Improvements](https://github.com/infradise/valkey_client/wiki/Developer-Experience-Improvements)
2. No GUI for Redis/Valkey? Try [Keyscope Jet](https://keyscope.dev)
3. Looking for a GUI built with `valkey_client`? Try [Keyscope](https://pub.dev/packages/keyscope)
4. Need real‑time watch for Redis/Valkey pods and services across multiple K8s clusters? Try [Visualkube Jet](https://jet.visualkube.com)


## Features

### 🚀 Performance & Scalability

| Feature | Description |
| :------ | :---------- |
| **Scalable Replica Reads**| Boost read performance by offloading read-only commands (e.g., `GET`, `EXISTS`) <br>to replica nodes. Supports `ReadPreference` settings (`master`, `preferReplica`, `replicaOnly`) to control traffic flow. |
| **Smart Load Balancing** | Built-in load balancing strategies (`Round-Robin`, `Random`) to efficiently distribute read traffic across available replicas. |
| **Multi-key Support**| Supports `MGET` across multiple nodes using smart Scatter-Gather pipelining.|
| **Sharded Pub/Sub & Atomic Counters** | Added support for high-performance cluster messaging (`SPUBLISH`/`SSUBSCRIBE`) and atomic integer operations (`INCR`/`DECR`). |

### 🛡️ High Availability & Resilience

| Feature | Description |
| :------ | :---------- |
| **Automatic Failover** |**Resilience:** The client now survives node failures. If a master node goes down <br>(connection refused/timeout), the client automatically refreshes the <br>cluster topology and reroutes commands to the new master without throwing an exception. |
| **High Availability & Resilience** | Automatically and transparently handles cluster topology changes <br>(`-MOVED` and `-ASK` redirections) to ensure robust failover, seamless scaling, and zero‑downtime operations. |
| **Automatic Replica Discovery**| Automatically detects and connects to replica nodes via <br>`INFO REPLICATION` (Standalone/Sentinel) to maintain an up-to-date pool of connections. |
| **Cluster Auto-Discovery** | Added `client.clusterSlots()` to fetch cluster topology <br>(via the `CLUSTER SLOTS` command), laying the foundation for full cluster support. |

### 🧩 Developer Experience & Tooling

| Feature | Description |
| :------ | :---------- |
| **Redis/Valkey Module Detector** | Retrieves module metadata to identify installed extensions <br>(e.g., `json`, `search`, `ldap`, `bf`). |
| **JSON Module Checker** | Pre-validates JSON module availability before execution. |
| **Server Metadata Discovery** | Access server details via `client.metadata` (Version, Mode, Server Name, <br>Max Databases) to write adaptive logic for Valkey vs. Redis. |
| **Enhanced Developer Experience** | Expanded `Redis` aliases to include Exceptions, Configuration, and Data Models <br>(`RedisException`, `RedisMessage`, etc.) for a seamless migration experience. |
| **Developer Experience** | Added `RedisClient` alias and smart redirection handling for better usability and stability. |
| **Type-Safe Exceptions** | Clear distinction between connection errors (`ValkeyConnectionException`), <br>server errors (`ValkeyServerException`), and client errors (`ValkeyClientException`). |
| **Observability** | Built-in logging. |

### 🔌 Connection & Configuration

| Feature | Description |
| :------ | :---------- |
| **Smart Database Selection** | First-class support for selecting databases (0-15+) on connection. <br>Automatically detects **Valkey 9.0+ Numbered Clusters** to enable multi-database support <br>in cluster mode, while maintaining backward compatibility with Redis Clusters (DB 0 only). |
| **Explicit Replica Configuration** | Added `explicitReplicas` to `ValkeyConnectionSettings` to manually define replica nodes, <br>solving connectivity issues in environments where auto-discovery fails. |
| **Cluster Client** | **ValkeyClusterClient:** Dedicated client for automatic command routing in cluster mode. <br>We recommend using `ValkeyClient` for Standalone/Sentinel and `ValkeyClusterClient` for cluster environments. |
| **Built-in Connection Pooling** | `ValkeyPool` for efficient connection management (used by Standalone and Cluster clients). |
| **Connection Pool Hardening** | **Smart Release Mechanism:** Prevents pool pollution by automatically detecting and <br>discarding "dirty" connections (e.g., inside Transaction or Pub/Sub) upon release. |
| **Command Timeout** | Includes a built-in command timeout (via `ValkeyConnectionSettings`) <br>to prevent client hangs on non-responsive servers. |

### 🔒 Security & Core

| Feature | Description |
| :------ | :---------- |
| **Enterprise Security** | Native SSL/TLS support compatible with major cloud providers (AWS, Azure, GCP). Supports custom security contexts (including self-signed certificates). |
| **Robust Parsing** | Full RESP3 parser handling all core data types (`+`, `-`, `$`, `*`, `:`). |
| **Pub/Sub Ready (Standalone/Sentinel)** | `subscribe()` returns a `Subscription` object with a `Stream` and a `Future<void> ready` for easy and reliable message handling. |
| **Production-Ready** | **Standalone/Sentinel:** Stable for production use.<br>**Cluster:** Stable for production use with full cluster support. |
