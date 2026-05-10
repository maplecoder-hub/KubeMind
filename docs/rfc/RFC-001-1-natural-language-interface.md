# RFC-001-1: Natural Language Interface

## Abstract

This document describes the design of the Natural Language Interface (NLI) component in KubeMind, which enables users to interact with Kubernetes clusters through natural language commands and queries. NLI serves as the primary input method for intent-driven operations.

## Detailed Design

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│              Natural Language Interface                      │
├────────────────────────────────────────────────────────────┤
│  Input Processing                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Speech-to-   │  │ Text Input   │  │ API Request  │     │
│  │ Text (Optional)│ │              │  │ Parser       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│           └────────────────┼──────────────────┘            │
│                           ↓                                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              LLM Processing Engine                    │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Intent       │  │ Entity       │                │  │
│  │  │ Recognition  │  │ Extraction   │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Context      │  │ Command      │                │  │
│  │  │ Manager      │  │ Generator    │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  └─────────────────────────────────────────────────────┘  │
│                           ↓                                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Response Generation                      │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Natural      │  │ Visual       │                │  │
│  │  │ Language     │  │ Response     │                │  │
│  │  │ Response     │  │ Generator    │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Action       │  │ Follow-up    │                │  │
│  │  │ Recommender  │  │ Suggestion   │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

---

### Core Components

#### 1. Intent Recognition

**Intent Taxonomy Specification**:

| Intent Category | Intent Types | Description |
|-----------------|--------------|-------------|
| **Cluster Management** | cluster_status, cluster_analyze, cluster_plan, cluster_upgrade | Cluster-level operations |
| **Resource Management** | resource_list, resource_describe, resource_create, resource_delete, resource_scale, resource_optimize | Resource operations |
| **Troubleshooting** | diagnose_pod, diagnose_node, diagnose_performance, diagnose_network | Fault diagnosis |
| **Security** | security_check, rbac_query, rbac_generate, vulnerability_scan | Security operations |
| **Capacity Planning** | predict_resources, capacity_status, capacity_recommend | Capacity planning |
| **Multi-Cluster** | cluster_compare, workload_migrate, disaster_recovery | Multi-cluster operations |
| **General** | help, explain, suggest, feedback | General queries |

**Intent Classification Process**:

| Step | Input | Process | Output |
|------|-------|---------|--------|
| 1 | User query | Keyword matching | Intent candidates |
| 2 | Intent candidates | LLM classification | Primary intent |
| 3 | Primary intent | Confidence calculation | Confidence score |
| 4 | Primary intent + Confidence | Threshold check (0.7) | Validated intent |

**Intent Classification Output**:

| Field | Type | Description |
|-------|------|-------------|
| intent | string | Classified intent name |
| confidence | float (0-1) | Classification confidence |
| reasoning | string | Classification reasoning |

---

#### 2. Entity Extraction

**Entity Types Specification**:

| Entity Category | Entity Types | Extraction Method |
|-----------------|--------------|-------------------|
| **Resources** | pod, deployment, service, node, namespace, configmap, secret, pv/pvc | Keyword + Pattern matching |
| **Identifiers** | resource_name, namespace_name, cluster_name, label_selector | Name pattern extraction |
| **Values** | replica_count, version, port, cpu/memory_limit, storage_size | Number + Unit extraction |
| **Time** | duration, timestamp, schedule | Time pattern extraction |
| **Boolean** | enable/disable, force, dry_run | Keyword detection |

**Entity Extraction Process**:

| Step | Input | Process | Output |
|------|-------|---------|--------|
| 1 | Intent + Query | Entity type identification | Entity types to extract |
| 2 | Query text | Pattern matching | Entity values |
| 3 | Entity values | Validation | Validated entities |
| 4 | Validated entities | Entity mapping | Entity dictionary |

---

#### 3. Context Manager

**Context Structure Specification**:

| Field | Type | Description |
|-------|------|-------------|
| session_id | string | Session identifier |
| current_cluster | string | Current cluster context |
| current_namespace | string | Current namespace context |
| focus_resource | ResourceReference | Focused resource |
| recent_intents | list[string] | Recent intent history |
| entity_memory | dict | Entity memory for multi-turn |
| user_preferences | dict | User preferences |
| temporal_context | dict | Time-related context |

**Context Management Rules**:

| Rule | Description | Example |
|------|-------------|---------|
| Namespace Inheritance | If namespace mentioned in turn N, use it in turn N+1 if not specified | Turn 1: "List pods in production" → Turn 2: "Scale nginx" → namespace=production |
| Resource Focus | Focus on resource mentioned in last turn | Turn 1: "Describe pod api-server-123" → Turn 2: "Why is it crashing?" → resource=api-server-123 |
| Intent Chain | Track intent chain for context | cluster_status → resource_list → resource_scale |

---

#### 4. Command Generator

**Command Templates Specification**:

| Intent | kubectl Command Template | API Template |
|--------|--------------------------|--------------|
| resource_scale | kubectl scale deployment/{name} --replicas={count} -n {namespace} | PATCH /apis/apps/v1/namespaces/{namespace}/deployments/{name}/scale |
| resource_list | kubectl get {resource_type} -n {namespace} | GET /api/v1/namespaces/{namespace}/{resource_type} |
| resource_describe | kubectl describe {resource_type}/{name} -n {namespace} | GET /api/v1/namespaces/{namespace}/{resource_type}/{name} |

**Command Generation Process**:

| Step | Input | Process | Output |
|------|-------|---------|--------|
| 1 | Intent + Entities | Template selection | Command template |
| 2 | Command template + Entities | Parameter substitution | Final command |
| 3 | Final command | Command validation | Validated command |

---

#### 5. Response Generator

**Response Generation Specification**:

| Field | Type | Description |
|-------|------|-------------|
| acknowledgment | string | Acknowledge user request |
| action_taken | string | Describe action performed |
| results | string | Show results |
| insights | string | Provide relevant insights |
| recommendations | list[string] | Recommend follow-up actions |
| follow_up | list[string] | Suggest follow-up queries |

---

### Interaction Patterns

#### Pattern 1: Direct Command

| Step | User Input | System Response | Context Update |
|------|------------|-----------------|----------------|
| 1 | "Scale deployment nginx to 5 replicas in production namespace" | "Scaled nginx to 5 replicas in production namespace. Previous: 3, Current: 5. Rollout will complete in 2 minutes." | namespace=production, resource=nginx |

#### Pattern 2: Multi-Turn Query

| Turn | User Input | System Response | Context Update |
|------|------------|-----------------|----------------|
| 1 | "How many pods are in the production namespace?" | "42 pods running in production namespace." | namespace=production, intent=resource_list |
| 2 | "Show me the ones with high CPU usage" | "3 pods have high CPU (>80%): api-server, worker-1, worker-2" | namespace=production, focus=high_cpu_pods |
| 3 | "Scale api-server to handle the load" | "Scaling api-server to 8 replicas in production namespace." | namespace=production, resource=api-server |

---

### Performance Considerations

| Performance Area | Configuration | Description |
|------------------|---------------|-------------|
| **Caching** | Intent cache: 1min TTL, Entity cache: session-based, Response template cache: 1hr TTL | Reduce LLM calls |
| **Streaming** | Stream LLM response for long explanations, Progressive rendering for complex results | Improve user experience |
| **Quality Threshold** | Confidence threshold: 0.7 | Minimum confidence for action |
| **Fallback** | If confidence < 0.7: ask clarifying questions, If intent ambiguous: show options | Error handling |

---

## References

- [LangChain Conversation Patterns](https://python.langchain.com/docs/)
- [Intent Recognition Best Practices](https://arxiv.org/)

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.1.0 | 2026-04-26 | KubeMind Team | Convert code to specification design |
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |