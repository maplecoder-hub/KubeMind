# RFC-003-2: Cluster State Knowledge Graph

## Abstract

This document describes the cluster state knowledge graph using Neo4j for representing cluster resources and relationships.

## Detailed Design

### Graph Model

```yaml
nodes:
  Node:
    properties: [name, status, cpu_capacity, memory_capacity, labels]
    
  Pod:
    properties: [name, namespace, status, cpu_request, memory_request]
    
  Service:
    properties: [name, namespace, type, cluster_ip, ports]
    
relationships:
  RUNS_ON: Pod -> Node
  EXPOSES: Service -> Pod
  DEPENDS_ON: Pod -> ConfigMap
  MOUNTS: Pod -> PVC
```

### Query Examples

```cypher
// Find pods running on unhealthy nodes
MATCH (p:Pod)-[:RUNS_ON]->(n:Node)
WHERE n.status = 'NotReady'
RETURN p.name, n.name

// Find dependency chains
MATCH (p:Pod)-[:DEPENDS_ON]->(c:ConfigMap)
RETURN p.name, c.name

// Find affected resources
MATCH (n:Node)-[:RUNS_ON*]-(p:Pod)-[:EXPOSES*]-(s:Service)
WHERE n.name = 'node-1'
RETURN s.name
```

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |