# RFC-003: Knowledge Base Layer

## Abstract

This document defines the design of the Knowledge Base Layer (Layer 3) of KubeMind, which provides intent knowledge, injected knowledge, and system state knowledge to support autonomous governance decisions.

## Detailed Design

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Knowledge Base Layer                            │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │          Knowledge Access Interface                   │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │   │
│  │  │ Intent       │  │ Injected     │  │ State     │  │   │
│  │  │ Knowledge    │  │ Knowledge    │  │ Knowledge │  │   │
│  │  │ Query        │  │ Query        │  │ Query     │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ↓                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          Knowledge Storage Systems                    │   │
│  │                                                        │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │    Intent Knowledge (Vector Store)               │ │   │
│  │  │  ┌──────────────────────────────────────────────┐│ │   │
│  │  │  │ ChromaDB / Weaviate                          ││ │   │
│  │  │  │ - Intent Patterns                            ││ │   │
│  │  │  │ - Blueprint Templates                        ││ │   │
│  │  │  │ - Behavior Models                            ││ │   │
│  │  │  │ - Translation Knowledge                      ││ │   │
│  │  │  └──────────────────────────────────────────────┘│ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  │                                                        │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │    Injected Knowledge (Vector Store + Graph)     │ │   │
│  │  │  ┌──────────────────────────────────────────────┐│ │   │
│  │  │  │ - Industry Experience                        ││ │   │
│  │  │  │ - Operations Experience                      ││ │   │
│  │  │  │ - Domain Knowledge                           ││ │   │
│  │  │  │ - Custom Policies                            ││ │   │
│  │  │  └──────────────────────────────────────────────┘│ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  │                                                        │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │    System State Graph (Neo4j)                    │ │   │
│  │  │  ┌──────────────────────────────────────────────┐│ │   │
│  │  │  │ Nodes: Intent, Blueprint, Cluster, Pod...    ││ │   │
│  │  │  │ Edges: intent->blueprint, deployed->pod...   ││ │   │
│  │  │  └──────────────────────────────────────────────┘│ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  │                                                        │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │    Decision & Achievement History                │ │   │
│  │  │  ┌──────────────────────────────────────────────┐│ │   │
│  │  │  │ PostgreSQL / TimescaleDB                      ││ │   │
│  │  │  │ - Autonomous Decisions                        ││ │   │
│  │  │  │ - Intent Achievements                         ││ │   │
│  │  │  │ - Drift Events                                ││ │   │
│  │  │  └──────────────────────────────────────────────┘│ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          Knowledge Integration Pipeline              │   │
│  │  ┌──────────────┐  ┌──────────────┐                │   │
│  │  │ Knowledge    │  │ State        │                │   │
│  │  │ Injection    │  │ Sync         │                │   │
│  │  │ Processor    │  │              │                │   │
│  │  └──────────────┘  └──────────────┘                │   │
│  │  ┌──────────────┐  ┌──────────────┐                │   │
│  │  │ Decision     │  │ Achievement  │                │   │
│  │  │ Recorder     │  │ Recorder     │                │   │
│  │  └──────────────┘  └──────────────┘                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

### Knowledge Types

#### Knowledge Type Summary

| Knowledge Type | Source | Storage | Purpose | Query Latency |
|---------------|--------|---------|---------|---------------|
| **Intent Knowledge** | Intent patterns, blueprint templates, behavior models | Vector Store (ChromaDB/Weaviate) | Intent understanding and translation | < 200ms |
| **Injected Knowledge** | Industry experience, operations practices, domain knowledge, custom policies | Vector Store + Knowledge Graph | Enhance autonomous decisions | < 300ms |
| **System State Graph** | Real-time cluster state, intent achievement | Neo4j Graph | State tracking and relationship mapping | < 100ms |
| **Decision History** | Historical autonomous decisions, outcomes, feedback | PostgreSQL/TimescaleDB | Learning and pattern matching | < 50ms |

---

### Intent Knowledge Base

#### Function

Provide knowledge for intent understanding and translation process.

#### Knowledge Categories

| Category | Content | Usage |
|----------|---------|-------|
| **Intent Patterns** | Typical intent expressions, keywords, entity patterns | Intent classification and entity extraction |
| **Blueprint Templates** | Pre-defined blueprint structures for common scenarios | Blueprint generation acceleration |
| **Behavior Models** | Behavior configuration patterns for different targets | Behavior blueprint derivation |

#### Intent Pattern Structure

| Field | Type | Description |
|-------|------|-------------|
| pattern_id | string | Pattern identifier |
| pattern_type | enum | Type: specification, behavior, constraint, deployment |
| keywords | list[string] | Keywords that trigger this pattern |
| entities | list[string] | Entities extracted from this pattern |
| typical_values | dict | Typical values for this pattern |
| confidence | float (0-1) | Pattern confidence level |
| applicability | dict | Where pattern applies |

#### Blueprint Template Structure

| Field | Type | Description |
|-------|------|-------------|
| template_id | string | Template identifier |
| template_name | string | Template display name |
| intent_category | enum | Category this template addresses |
| deployment_mode | enum | Deployment mode: cloud, on-prem, hybrid, edge |
| template_content | dict | Template structure |
| parameters | list[TemplateParameter] | Template parameters |
| applicability_conditions | dict | Conditions for template use |
| success_rate | float (0-1) | Historical success rate |

#### Template Parameter Structure

| Field | Type | Description |
|-------|------|-------------|
| name | string | Parameter name |
| type | enum | Parameter type: string, integer, float, boolean |
| default_value | any | Default value if not specified |
| required | boolean | Whether parameter is required |
| validation_rules | list[string] | Validation rules for parameter |

---

### Injected Knowledge Integration

#### Function

Manage and retrieve external injected knowledge (see RFC-006).

#### Injection Types

| Type | Description | Domains/Applicability |
|------|-------------|----------------------|
| **Industry Experience** | Domain-specific patterns and best practices | financial_services, ecommerce, iot, enterprise |
| **Operations Experience** | Operational best practices | scaling, cost_optimization, fault_handling, tuning |
| **Domain Knowledge** | Technical domain expertise | database, network, security, storage |
| **Custom Policies** | Organization-specific rules | org-specific security, compliance, cost policies |
| **Compliance Frameworks** | Regulatory compliance knowledge | cis-kubernetes, nist-csf, sox, pci-dss |

#### Knowledge Retrieval for Governance

| Input | Type | Description |
|-------|------|-------------|
| intent | SystemIntentDeclaration | Target intent |
| drift_report | DriftReport | Drift analysis result |
| context | GovernanceContext | Governance context |

| Output | Type | Description |
|--------|------|-------------|
| knowledge_items | list[KnowledgeInjection] | Retrieved knowledge items |
| applicable_scenarios | list[Scenario] | Matching scenarios from knowledge |
| recommended_actions | list[Action] | Recommended actions from scenarios |
| confidence | float (0-1) | Overall confidence |
| provenance_summary | dict | Summary of knowledge sources |

---

### System State Knowledge Graph

#### Function

Track system state and relationships through a graph structure.

#### Graph Node Types

| Node Type | Properties | Relationships |
|-----------|------------|---------------|
| **Intent** | intent_id, natural_language, status, created_at, updated_at | intent_has_blueprint, intent_has_achievement, intent_has_drift |
| **Blueprint** | blueprint_id, intent_id, version, status | blueprint_deployed_to |
| **Cluster** | cluster_id, name, provider, region | cluster_has_node, cluster_has_pod |
| **Node** | node_id, name, status, cpu_capacity, memory_capacity | pod_runs_on_node |
| **Pod** | pod_id, name, namespace, status | pod_runs_on_node |
| **Achievement** | achievement_id, intent_id, timestamp, overall_percentage | intent_has_achievement |
| **DriftEvent** | drift_id, intent_id, timestamp, drift_type, drift_severity | intent_has_drift |

#### Graph Relationship Types

| Relationship | From Node | To Node | Properties |
|--------------|-----------|---------|------------|
| intent_has_blueprint | Intent | Blueprint | created_at |
| blueprint_deployed_to | Blueprint | Cluster | deployed_at, status |
| intent_has_achievement | Intent | Achievement | measured_at |
| intent_has_drift | Intent | DriftEvent | detected_at |
| pod_runs_on_node | Pod | Node | since |
| cluster_has_node | Cluster | Node | - |
| cluster_has_pod | Cluster | Pod | - |

#### Intent State Query Result

| Field | Type | Description |
|-------|------|-------------|
| intent | dict | Intent node data |
| blueprints | list[dict] | Connected blueprint nodes |
| achievements | list[dict] | Connected achievement nodes |
| state_graph | dict | Subgraph visualization data |

---

### Decision & Achievement History

#### Function

Store and query historical autonomous decisions and outcomes.

#### Decision Record Structure

| Field | Type | Description |
|-------|------|-------------|
| decision_id | string | Decision identifier |
| intent_id | string | Associated intent |
| agent_id | string | Agent that made decision |
| timestamp | datetime | Decision timestamp |
| decision_type | string | Type of decision |
| decision_data | dict | Decision parameters |
| reasoning | string | Decision reasoning |
| context | dict | Decision context |
| outcome | DecisionOutcome | Decision outcome (optional) |
| feedback | string | Feedback (optional) |

#### Decision Outcome Structure

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Whether decision succeeded |
| achievement_improvement | float | Improvement in achievement score |
| execution_time_seconds | integer | Execution duration |
| side_effects | list[string] | Any side effects observed |

#### Achievement Record Structure

| Field | Type | Description |
|-------|------|-------------|
| achievement_id | string | Achievement identifier |
| intent_id | string | Associated intent |
| timestamp | datetime | Measurement timestamp |
| overall_percentage | float (0-100) | Overall achievement score |
| specification_match | float (0-100) | Specification match percentage |
| behavior_match | float (0-100) | Behavior match percentage |
| constraint_match | float (0-100) | Constraint match percentage |
| deployment_match | float (0-100) | Deployment match percentage |
| drift_detected | boolean | Whether drift was detected |
| autonomous_actions_count | integer | Actions taken |

---

### Knowledge Access API

#### API Functions

| Function | Inputs | Outputs | Purpose |
|----------|--------|---------|---------|
| get_context_for_translation | Intent | TranslationKnowledgeContext | Get knowledge for intent translation |
| get_context_for_governance | Intent, DriftReport | GovernanceKnowledgeContext | Get knowledge for autonomous governance |
| query_intent_patterns | Intent classification | Intent patterns | Get matching intent patterns |
| query_blueprint_templates | Intent specification | Blueprint templates | Get matching blueprint templates |
| retrieve_injected_knowledge | Intent, Drift, Context | Injected knowledge | Get relevant injected knowledge |
| query_similar_decisions | Context, Decision type | Decision records | Get similar historical decisions |
| query_intent_state | Intent ID | Intent state | Get current intent state from graph |

#### Translation Knowledge Context

| Field | Type | Description |
|-------|------|-------------|
| intent_knowledge | IntentKnowledgeResult | Intent patterns and templates |
| injected_knowledge | InjectedKnowledgeResult | Injected knowledge for translation |
| combined_prompt | string | Combined prompt for LLM |

#### Governance Knowledge Context

| Field | Type | Description |
|-------|------|-------------|
| injected_knowledge | InjectedKnowledgeResult | Injected knowledge for governance |
| similar_decisions | list[DecisionRecord] | Similar historical decisions |
| current_state | IntentStateResult | Current intent state |
| combined_prompt | string | Combined prompt for LLM |

---

### Knowledge Ingestion Pipeline

#### Pipeline Stages

| Pipeline | Frequency/Trigger | Steps |
|----------|-------------------|-------|
| **Intent Knowledge Ingestion** | On update | Load knowledge files → Validate schema → Extract embeddings → Store in vector DB → Update indices |
| **Injected Knowledge Ingestion** | Via RFC-006 interface | Receive injection request → Validate content → Validate applicability → Extract embeddings → Create graph nodes → Store in vector DB → Update knowledge graph → Activate knowledge |
| **State Sync Pipeline** | Every 10s | Collect cluster state → Collect intent achievement → Update state graph → Sync decision history |
| **Decision Recording Pipeline** | On action completion | Receive decision event → Record decision → Record outcome → Calculate feedback score → Update knowledge metrics |

---

### Performance Targets

| Metric | Target | Description |
|--------|--------|-------------|
| Intent knowledge query | < 200ms | Query intent patterns/templates |
| Injected knowledge query | < 300ms | Query injected knowledge |
| State graph query | < 100ms | Query system state graph |
| Decision history query | < 50ms | Query historical decisions |
| Combined context query | < 500ms | Combined knowledge retrieval |
| Knowledge relevance | > 85% | Relevance of retrieved knowledge |
| Pattern match accuracy | > 90% | Pattern matching accuracy |
| Scenario applicability | > 80% | Scenario match rate |
| State sync delay | < 10s | State freshness |
| Decision recording delay | < 5s | Decision recording latency |
| Achievement update delay | < 10s | Achievement update latency |
| Intent patterns capacity | > 100 | Stored intent patterns |
| Blueprint templates capacity | > 50 | Stored blueprint templates |
| Injected knowledge capacity | > 1000 | Stored injected knowledge items |
| Decision history capacity | > 10000 | Stored decision records |

---

## References

- [LlamaIndex RAG](https://docs.llamaindex.ai/)
- [Neo4j Knowledge Graph](https://neo4j.com/)
- [ChromaDB Vector Store](https://www.trychroma.com/)
- [RFC-006: Knowledge Injection Interface](./RFC-006-knowledge-injection-interface.md)

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 2.1.0 | 2026-04-26 | KubeMind Team | Convert code to specification design |
| 2.0.0 | 2026-04-26 | KubeMind Team | Intent-driven knowledge redesign with injection integration |
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |