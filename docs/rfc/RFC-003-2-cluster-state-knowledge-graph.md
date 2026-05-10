# RFC-003-2: Cluster State Knowledge Graph

## Abstract

This document describes the cluster state knowledge graph using Neo4j for representing cluster resources and relationships.

## Detailed Design

### Graph Model

#### Node Types Specification

**Node Type: Node**

| Property | Type | Description |
|----------|------|-------------|
| `name` | String | Unique identifier for the node |
| `status` | String | Current node status (Ready/NotReady) |
| `cpu_capacity` | Integer | Total CPU capacity in cores |
| `memory_capacity` | Integer | Total memory capacity in bytes |
| `labels` | Map | Key-value labels for node identification |

**Node Type: Pod**

| Property | Type | Description |
|----------|------|-------------|
| `name` | String | Unique identifier for the pod |
| `namespace` | String | Namespace where pod is deployed |
| `status` | String | Current pod phase (Running/Pending/etc.) |
| `cpu_request` | Float | CPU resources requested |
| `memory_request` | Integer | Memory resources requested in bytes |

**Node Type: Service**

| Property | Type | Description |
|----------|------|-------------|
| `name` | String | Unique identifier for the service |
| `namespace` | String | Namespace where service is deployed |
| `type` | String | Service type (ClusterIP/NodePort/LoadBalancer) |
| `cluster_ip` | String | Cluster IP address assigned |
| `ports` | List | List of port configurations |

#### Relationship Types Specification

| Relationship | Source | Target | Description |
|--------------|--------|--------|-------------|
| `RUNS_ON` | Pod | Node | Indicates the node where a pod is running |
| `EXPOSES` | Service | Pod | Indicates pods exposed by a service |
| `DEPENDS_ON` | Pod | ConfigMap | Indicates config dependencies |
| `MOUNTS` | Pod | PVC | Indicates persistent volume claims mounted |

### Query Patterns

#### Query Specification: Find Pods on Unhealthy Nodes

| Aspect | Description |
|--------|-------------|
| **Purpose** | Identify pods running on nodes with NotReady status |
| **Pattern** | Traverse RUNS_ON relationship from Pod to Node |
| **Filter** | Node status equals 'NotReady' |
| **Output** | Pod name and node name pairs |

#### Query Specification: Find Dependency Chains

| Aspect | Description |
|--------|-------------|
| **Purpose** | Identify ConfigMap dependencies for pods |
| **Pattern** | Traverse DEPENDS_ON relationship from Pod to ConfigMap |
| **Output** | Pod name and ConfigMap name pairs |

#### Query Specification: Find Affected Resources

| Aspect | Description |
|--------|-------------|
| **Purpose** | Find all services affected by a node failure |
| **Pattern** | Multi-hop traversal from Node through Pods to Services |
| **Filter** | Node name equals target node identifier |
| **Output** | Service names impacted by the node |

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |
| 1.1.0 | 2026-04-26 | KubeMind Team | Convert code to specification design |