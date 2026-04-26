# KubeMind Technology Stack Decision Document

## Version: 1.0.0
## Date: 2026-04-22
## Status: Approved

---

## Executive Summary

This document defines the definitive technology stack for KubeMind, ensuring deterministic code generation by AI systems. All RFC documents must conform to these specifications.

---

## 1. Primary Language Strategy

### Decision: **Hybrid (Python + Go)**

```
┌─────────────────────────────────────────────────────────────┐
│ Python Services (AI Layer)                                   │
│ ├── Layer 1: Human-Machine Interface                         │
│ ├── Layer 2: Agent Orchestration Brain                       │
│ ├── Layer 3: Knowledge Base                                   │
│ └─────────────────────────────────────────────────────────────┘
                    ↓ gRPC/REST
┌─────────────────────────────────────────────────────────────┐
│ Go Services (Infrastructure Layer)                           │
│ ├── Layer 4: Execution & Observation                         │
│ │   ├── K8s Controller (controller-runtime)                  │
│ │   ├── Event Watcher                                         │
│ │   ├── Safety Validator                                      │
│ │   └── API Gateway                                           │
│ └─────────────────────────────────────────────────────────────┘
```

### Language Allocation Table

| Component | Language | Package Path | Rationale |
|-----------|----------|--------------|-----------|
| CLI Tool | Go | `cmd/kubemind/` | Performance, small binary |
| API Gateway | Go | `pkg/gateway/` | High throughput, routing |
| K8s Controller | Go | `pkg/controller/` | controller-runtime patterns |
| Event Processor | Go | `pkg/events/` | Low latency streaming |
| Safety Validator | Go | `pkg/safety/` | Critical path performance |
| Agent Coordinator | Python | `pkg/agents/coordinator/` | LangChain integration |
| Specialized Agents | Python | `pkg/agents/*/` | ML models, LLM inference |
| Knowledge Base | Python | `pkg/knowledge/` | RAG, vector ops |
| Natural Language Interface | Python | `pkg/nli/` | LLM processing |
| Dashboard Backend | Python | `pkg/dashboard/` | FastAPI async |
| ML Models | Python | `pkg/models/` | TensorFlow, PyTorch |

### Version Requirements

| Language | Version | Constraint |
|----------|---------|------------|
| Python | 3.11.x | `>=3.11.0,<3.12.0` |
| Go | 1.22.x | `>=1.22.0,<1.23.0` |

---

## 2. LLM & Agent Framework

### Decision: **LangChain + LlamaIndex**

### LangChain (Primary)

```yaml
framework: langchain
version: "0.1.20"
purpose:
  - Agent Coordinator orchestration
  - Tool execution
  - Multi-agent workflow (LangGraph)
  - Conversation memory

packages:
  - langchain: "0.1.20"
  - langchain-core: "0.1.52"
  - langchain-community: "0.0.24"
  - langgraph: "0.0.55"
  - langchain-openai: "0.1.22"
  - langchain-anthropic: "0.1.22"
```

### LlamaIndex (Secondary - RAG)

```yaml
framework: llama_index
version: "0.10.55"
purpose:
  - K8S best practices RAG retrieval
  - Document parsing
  - Vector store indexing
  - Knowledge context building

packages:
  - llama-index-core: "0.10.55"
  - llama-index-readers-file: "0.1.29"
  - llama-index-vector-stores-chroma: "0.1.11"
  - llama-index-vector-stores-weaviate: "0.2.3"
  - llama-index-embeddings-openai: "0.1.11"
  - llama-index-llms-openai: "0.1.27"
```

### Integration Pattern

```python
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader
from langchain.retrievers import LlamaIndexRetriever

llm = ChatOpenAI(model="gpt-4-turbo-preview", temperature=0.7)
documents = SimpleDirectoryReader("./knowledge/best-practices").load_data()
index = VectorStoreIndex.from_documents(documents)
retriever = LlamaIndexRetriever(index=index, llm=llm)
```

---

## 3. Vector Database

### Decision: **ChromaDB (Development) → Weaviate (Production)**

### ChromaDB Configuration

```yaml
vector_store:
  development:
    type: chromadb
    version: "0.5.3"
    mode: persistent
    path: "./data/vectors"
    collection_name: "k8s_best_practices"
    embedding_function: "text-embedding-3-small"
    dimension: 1536
    
  packages:
    - chromadb: "0.5.3"
```

### Weaviate Configuration

```yaml
vector_store:
  production:
    type: weaviate
    version: "1.26.1"
    deployment: kubernetes
    helm_chart: weaviate/weaviate
    helm_version: "0.1.0"
    
  schema:
    class: K8SBestPractice
    properties:
      - name: content
        dataType: ["text"]
      - name: category
        dataType: ["string"]
      - name: source
        dataType: ["string"]
      - name: doc_type
        dataType: ["string"]
      
  vectorizer: text2vec-openai
```

### Code Pattern (Deterministic)

```python
from chromadb import Client, Settings
from chromadb.utils import embedding_functions

class VectorStoreFactory:
    @staticmethod
    def create(config: VectorStoreConfig) -> VectorStore:
        if config.type == "chromadb":
            return ChromaDBVectorStore(
                path=config.path,
                collection_name=config.collection_name,
                embedding_function=embedding_functions.OpenAIEmbeddingFunction(
                    api_key=config.api_key,
                    model_name="text-embedding-3-small"
                )
            )
        elif config.type == "weaviate":
            return WeaviateVectorStore(
                url=config.url,
                class_name=config.class_name
            )
```

---

## 4. Knowledge Graph Database

### Decision: **Neo4j**

```yaml
graph_database:
  type: neo4j
  version: "5.20.0"
  driver_version: "5.20.0"
  
  deployment:
    helm_chart: neo4j/neo4j
    helm_version: "4.4.15"
    
  connection:
    uri: "bolt://neo4j:7687"
    auth:
      username: neo4j
      password: ${NEO4J_PASSWORD}
      
  packages:
    - neo4j: "5.20.0"
    - neo4j-python-driver: "5.20.0"
```

### Definitive Graph Schema

```yaml
node_labels:
  Node:
    properties:
      - name: {type: string, index: true}
      - status: {type: string}
      - cpu_capacity: {type: float}
      - memory_capacity: {type: float}
      - labels: {type: map}
      - creation_timestamp: {type: datetime}
      
  Pod:
    properties:
      - name: {type: string, index: true}
      - namespace: {type: string, index: true}
      - status: {type: string}
      - cpu_request: {type: float}
      - memory_request: {type: float}
      - node_name: {type: string}
      - creation_timestamp: {type: datetime}
      
  Service:
    properties:
      - name: {type: string, index: true}
      - namespace: {type: string, index: true}
      - type: {type: string}
      - cluster_ip: {type: string}
      - ports: {type: list}
      
  Deployment:
    properties:
      - name: {type: string, index: true}
      - namespace: {type: string, index: true}
      - replicas: {type: integer}
      - available_replicas: {type: integer}
      
  ConfigMap:
    properties:
      - name: {type: string}
      - namespace: {type: string}
      
  Secret:
    properties:
      - name: {type: string}
      - namespace: {type: string}
      
  PVC:
    properties:
      - name: {type: string}
      - namespace: {type: string}
      - storage: {type: string}
      - storage_class: {type: string}
      
relationship_types:
  RUNS_ON:
    from: Pod
    to: Node
    properties:
      - since: {type: datetime}
      
  EXPOSES:
    from: Service
    to: Pod
    properties:
      - port: {type: integer}
      
  DEPENDS_ON:
    from: Pod
    to: [ConfigMap, Secret]
    properties:
      - mount_path: {type: string}
      
  MANAGES:
    from: Deployment
    to: Pod
    
  MOUNTS:
    from: Pod
    to: PVC
    properties:
      - mount_path: {type: string}
```

### Deterministic Code Pattern

```python
from neo4j import GraphDatabase

class KnowledgeGraphClient:
    def __init__(self, uri: str, username: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(username, password))
    
    def create_node(self, tx, label: str, name: str, properties: dict):
        query = f"""
        MERGE (n:{label} {{name: $name}})
        SET n += $properties
        RETURN n
        """
        tx.run(query, name=name, properties=properties)
    
    def create_relationship(self, tx, rel_type: str, from_name: str, to_name: str):
        query = f"""
        MATCH (a {{name: $from_name}}), (b {{name: $to_name}})
        MERGE (a)-[r:{rel_type}]->(b)
        RETURN r
        """
        tx.run(query, from_name=from_name, to_name=to_name)
```

---

## 5. Backend Framework

### Decision: **FastAPI**

```yaml
backend:
  framework: fastapi
  version: "0.111.0"
  
  packages:
    - fastapi: "0.111.0"
    - uvicorn[standard]: "0.29.0"
    - pydantic: "2.7.3"
    - pydantic-settings: "2.2.1"
    - python-multipart: "0.0.9"
    - websockets: "12.0"
    
  middleware:
    - cors: CORSMiddleware
    - logging: LoggingMiddleware
    - tracing: OpenTelemetryMiddleware
```

### Deterministic Application Structure

```python
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

app = FastAPI(
    title="KubeMind API",
    version="0.1.0",
    docs_url="/api/docs",
    openapi_url="/api/openapi.json"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)
```

---

## 6. Kubernetes Integration

### Decision: **Hybrid (client-python + controller-runtime)**

### Python Layer

```yaml
k8s_client:
  python:
    package: kubernetes
    version: "29.0.0"
    purpose:
      - Context gathering
      - Resource queries
      - Agent operations
      
  packages:
    - kubernetes: "29.0.0"
```

### Go Layer

```yaml
k8s_client:
  go:
    framework: controller-runtime
    version: "0.17.2"
    purpose:
      - Controller patterns
      - Event watching
      - Webhooks
      - Leader election
      
  packages:
    - sigs.k8s.io/controller-runtime: "v0.17.2"
    - k8s.io/client-go: "v0.29.0"
    - k8s.io/apimachinery: "v0.29.0"
    - k8s.io/api: "v0.29.0"
```

### Go Module Definition

```go
module github.com/kubemind/kubemind

go 1.22

require (
    sigs.k8s.io/controller-runtime v0.17.2
    k8s.io/client-go v0.29.0
    k8s.io/apimachinery v0.29.0
    k8s.io/api v0.29.0
    github.com/go-logr/logr v1.4.1
)
```

---

## 7. Message Queue & Communication

### Decision: **Kafka (Production) + Redis (Development/Caching)**

```yaml
message_queue:
  production:
    type: kafka
    version: "3.7.0"
    deployment: strimzi-kafka-operator
    
  development:
    type: redis
    version: "7.2.4"
    purpose: pub-sub, caching
    
  packages:
    python:
      - aiokafka: "0.9.0"
      - redis: "5.0.4"
    go:
      - github.com/segmentio/kafka-go: "v0.4.47"
      - github.com/redis/go-redis/v9: "v9.5.1"
```

---

## 8. Database (Historical Decisions)

### Decision: **PostgreSQL + TimescaleDB Extension**

```yaml
database:
  type: postgresql
  version: "16.2"
  extension: timescaledb
  extension_version: "2.14.0"
  
  deployment:
    helm_chart: timescale/timescaledb-single
    helm_version: "0.10.0"
    
  packages:
    python:
      - psycopg[binary]: "3.1.19"
      - sqlalchemy: "2.0.30"
    go:
      - github.com/jackc/pgx/v5: "v5.5.5"
```

### Definitive Schema

```sql
CREATE TABLE decisions (
    decision_id VARCHAR(64) PRIMARY KEY,
    agent_id VARCHAR(64) NOT NULL,
    agent_type VARCHAR(32) NOT NULL,
    decision_type VARCHAR(64) NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    action_type VARCHAR(64) NOT NULL,
    action_params JSONB NOT NULL,
    reasoning TEXT,
    confidence FLOAT NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    affected_resources JSONB,
    requires_approval BOOLEAN DEFAULT FALSE,
    approval_status VARCHAR(16) DEFAULT 'not_required',
    outcome_status VARCHAR(16) DEFAULT 'pending',
    outcome_data JSONB,
    success BOOLEAN,
    context JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_decisions_agent ON decisions(agent_id);
CREATE INDEX idx_decisions_type ON decisions(decision_type);
CREATE INDEX idx_decisions_timestamp ON decisions(timestamp DESC);

SELECT create_hypertable('decisions', 'timestamp', if_not_exists => TRUE);
```

---

## 9. Frontend Stack

### Decision: **React + TypeScript + Ant Design**

```yaml
frontend:
  framework: react
  version: "18.2.0"
  language: typescript
  typescript_version: "5.4.5"
  
  packages:
    dependencies:
      - react: "18.2.0"
      - react-dom: "18.2.0"
      - antd: "5.17.3"
      - @ant-design/icons: "5.3.0"
      - @ant-design/charts: "2.0.3"
      - axios: "1.6.8"
      - socket.io-client: "4.7.5"
      - react-router-dom: "6.23.0"
      - zustand: "4.5.2"
      
    devDependencies:
      - vite: "5.2.10"
      - "@vitejs/plugin-react": "4.2.1"
      - typescript: "5.4.5"
      - "@types/react": "18.2.79"
      - "@types/react-dom": "18.2.25"
```

---

## 10. ML/AI Libraries

### Decision: Determinative Version Set

```yaml
ml_libraries:
  core:
    - torch: "2.3.0"
    - tensorflow: "2.16.1"
    - numpy: "1.26.4"
    - pandas: "2.2.2"
    - scikit-learn: "1.4.2"
    
  reinforcement_learning:
    - stable-baselines3: "2.3.0"
    - gymnasium: "0.29.1"
    
  time_series:
    - prophet: "1.1.5"
    
  optimization:
    - deap: "1.4.1"
```

---

## 11. Development & DevOps Tools

```yaml
devops:
  containerization:
    - docker: "26.1.0"
    - docker-compose: "2.27.0"
    
  kubernetes:
    - helm: "3.14.4"
    - kubectl: "1.29.0"
    
  ci_cd:
    - github-actions
    
  linting_python:
    - ruff: "0.4.3"
    - mypy: "1.10.0"
    - black: "24.4.2"
    
  linting_go:
    - golangci-lint: "1.57.2"
    
  testing_python:
    - pytest: "8.2.0"
    - pytest-asyncio: "0.23.6"
    - pytest-cov: "5.0.0"
    
  testing_go:
    - testing (stdlib)
```

---

## 12. Project Directory Structure (Determinative)

```
kubemind/
├── cmd/                          # Go entrypoints
│   └── kubemind/
│       └── main.go                # CLI entrypoint
│
├── pkg/                          # Public packages (importable)
│   ├── controller/               # Go: K8s controller
│   │   ├── controller.go
│   │   ├── reconciler.go
│   │   └── webhooks/
│   │
│   ├── events/                   # Go: Event processor
│   │   ├── watcher.go
│   │   ├── processor.go
│   │   └── filter.go
│   │
│   ├── safety/                   # Go: Safety validator
│   │   ├── validator.go
│   │   ├── rollback.go
│   │   └── rules.go
│   │
│   ├── gateway/                  # Go: API gateway
│   │   ├── gateway.go
│   │   ├── router.go
│   │   └── middleware.go
│   │
│   ├── agents/                   # Python: Agent system
│   │   ├── coordinator/
│   │   │   ├── coordinator.py
│   │   │   ├── registry.py
│   │   │   ├── dispatcher.py
│   │   │   └── conflict_resolver.py
│   │   │
│   │   ├── planner/              # Cluster Planner Agent
│   │   │   ├── agent.py
│   │   │   ├── workload_analyzer.py
│   │   │   └── architecture_designer.py
│   │   │
│   │   ├── scheduler/            # Scheduler Governor Agent
│   │   │   ├── agent.py
│   │   │   ├── node_scorer.py
│   │   │   └── rl_engine.py
│   │   │
│   │   ├── resource/             # Resource Governor Agent
│   │   │   ├── agent.py
│   │   │   ├── quota_manager.py
│   │   │   ├── capacity_planner.py
│   │   │
│   │   ├── network/              # Network Governor Agent
│   │   │   ├── agent.py
│   │   │   ├── policy_generator.py
│   │   │
│   │   ├── storage/              # Storage Governor Agent
│   │   │   ├── agent.py
│   │   │   ├── class_selector.py
│   │   │
│   │   ├── security/             # Security Governor Agent
│   │   │   ├── agent.py
│   │   │   ├── rbac_generator.py
│   │   │   ├── compliance_auditor.py
│   │   │
│   │   ├── fault/                # Fault Healer Agent
│   │   │   ├── agent.py
│   │   │   ├── predictor.py
│   │   │   ├── healer.py
│   │   │
│   │   ├── multicluster/         # Multi-Cluster Agent
│   │   │   ├── agent.py
│   │   │   ├── federator.py
│   │   │   ├── migrator.py
│   │   │
│   │   └── base.py               # Agent base class
│   │
│   ├── knowledge/                # Python: Knowledge base
│   │   ├── rag/
│   │   │   ├── vector_store.py
│   │   │   ├── retriever.py
│   │   │   ├── indexer.py
│   │   │
│   │   ├── graph/
│   │   │   ├── neo4j_client.py
│   │   │   ├── schema.py
│   │   │   ├── sync.py
│   │   │
│   │   ├── history/
│   │   │   ├── db_client.py
│   │   │   ├── recorder.py
│   │   │   ├── querier.py
│   │   │
│   │   └── api.py                # Unified knowledge API
│   │
│   ├── nli/                      # Python: Natural language interface
│   │   ├── intent_recognizer.py
│   │   ├── entity_extractor.py
│   │   ├── context_manager.py
│   │   ├── response_generator.py
│   │   └── command_generator.py
│   │
│   ├── dashboard/                # Python: Dashboard backend
│   │   ├── api/
│   │   │   ├── routes.py
│   │   │   ├── websocket.py
│   │   │   └── handlers.py
│   │   │
│   │   ├── services/
│   │   │   ├── cluster_overview.py
│   │   │   ├── resource_dashboard.py
│   │   │   ├── decision_dashboard.py
│   │   │   └── alert_dashboard.py
│   │   │
│   │   └── app.py                # FastAPI app
│   │
│   ├── models/                   # Python: ML models
│   │   ├── rl/
│   │   │   ├── scheduler_ppo.py
│   │   │   ├── env.py
│   │   │
│   │   ├── prediction/
│   │   │   ├── capacity_prophet.py
│   │   │   ├── fault_lstm.py
│   │   │
│   │   └── optimization/
│   │   │   ├── multi_objective.py
│   │   │
│   └── k8s/                      # Python: K8s client wrapper
│       ├── client.py
│       ├── resources.py
│       └── watcher.py
│
├── internal/                     # Private packages (internal)
│   ├── config/
│   │   ├── config.go
│   │   └── config.py
│   │
│   └── constants/
│       ├── constants.go
│       └── constants.py
│
├── api/                          # API definitions
│   ├── crd/
│   │   ├── v1alpha1/
│   │   │   ├── clustergovernancepolicy_types.go
│   │   │   ├── schedulingpolicy_types.go
│   │   │   ├── faulthandlingpolicy_types.go
│   │   │
│   │   └── register.go
│   │
│   ├── openapi/
│   │   └ openapi.yaml
│   │
│   └── proto/                    # gRPC definitions (Go-Python communication)
│       ├── agent.proto
│       ├── decision.proto
│       └── knowledge.proto
│
├── web/                          # Frontend (React)
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── hooks/
│   │   ├── stores/
│   │   ├── types/
│   │   ├── App.tsx
│   │   └ main.tsx
│   │
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── index.html
│
├── config/                       # Configuration files
│   ├── default/
│   │   ├── llm.yaml
│   │   ├── agents.yaml
│   │   ├── knowledge.yaml
│   │
│   ├── samples/
│   │   ├── cluster-governance-policy.yaml
│   │
│   └── crd/
│   │   ├── kustomization.yaml
│   │
│   └── rbac/
│   │   ├── kustomization.yaml
│   │   ├── role.yaml
│   │   ├── role_binding.yaml
│
├── manifests/                    # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── namespace.yaml
│
├── helm/                         # Helm charts
│   └ kubemind/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   ├── templates/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── configmap.yaml
│   │   │
│   │   └── README.md
│
├── docs/                         # Documentation
│   ├── rfc/                      # RFC documents
│   ├── TECH-STACK.md             # This document
│   ├── ARCHITECTURE.md           # Architecture overview
│   ├── CONTRIBUTING.md
│   └── API.md
│
├── knowledge/                    # Knowledge base documents
│   ├── best-practices/
│   │   ├── scheduling.md
│   │   ├── resource-management.md
│   │   ├── security.md
│   │   ├── networking.md
│   │   ├── storage.md
│   │
│   └── troubleshooting/
│       ├── common-issues.md
│       ├── diagnostics.md
│
├── tests/                        # Tests
│   ├── python/
│   │   ├── unit/
│   │   ├── integration/
│   │   ├── conftest.py
│   │
│   └── go/
│       ├── unit/
│       ├── integration/
│
├── scripts/                      # Utility scripts
│   ├── build.sh
│   ├── test.sh
│   ├── generate-crd.sh
│   └─  install.sh
│
├── go.mod                        # Go module definition
├── go.sum                        # Go dependencies checksum
├── pyproject.toml                # Python project config
├── requirements.txt              # Python dependencies
├── requirements-dev.txt          # Python dev dependencies
├── Makefile                      # Build automation
├── Dockerfile                    # Multi-stage build
├── docker-compose.yaml           # Local development
├── LICENSE                       # Apache 2.0
├── README.md                     # Project README
├── ROADMAP.md                    # Roadmap
└── .gitignore                    # Git ignore patterns
```

---

## 13. Package Version Lock File

### requirements.txt (Python)

```
langchain==0.1.20
langchain-core==0.1.52
langchain-community==0.0.24
langgraph==0.0.55
langchain-openai==0.1.22
langchain-anthropic==0.1.22
llama-index-core==0.10.55
llama-index-readers-file==0.1.29
llama-index-vector-stores-chroma==0.1.11
llama-index-vector-stores-weaviate==0.2.3
llama-index-embeddings-openai==0.1.11
llama-index-llms-openai==0.1.27
chromadb==0.5.3
neo4j==5.20.0
fastapi==0.111.0
uvicorn[standard]==0.29.0
pydantic==2.7.3
pydantic-settings==2.2.1
websockets==12.0
kubernetes==29.0.0
aiokafka==0.9.0
redis==5.0.4
psycopg[binary]==3.1.19
sqlalchemy==2.0.30
torch==2.3.0
tensorflow==2.16.1
numpy==1.26.4
pandas==2.2.2
scikit-learn==1.4.2
stable-baselines3==2.3.0
gymnasium==0.29.1
prophet==1.1.5
deap==1.4.1
```

### go.mod (Go)

```go
module github.com/kubemind/kubemind

go 1.22

require (
    sigs.k8s.io/controller-runtime v0.17.2
    k8s.io/client-go v0.29.0
    k8s.io/apimachinery v0.29.0
    k8s.io/api v0.29.0
    github.com/go-logr/logr v1.4.1
    github.com/segmentio/kafka-go v0.4.47
    github.com/redis/go-redis/v9 v9.5.1
    github.com/jackc/pgx/v5 v5.5.5
    google.golang.org/grpc v1.63.2
    google.golang.org/protobuf v1.34.1
)
```

---

## 14. Verification Checklist

Before AI generates code, verify:

- [ ] All package versions are locked (no ranges)
- [ ] All imports use exact paths from directory structure
- [ ] All data structures use Pydantic models with exact field names
- [ ] All database schemas are SQL-compliant
- [ ] All gRPC/REST API endpoints are defined
- [ ] All environment variables are documented
- [ ] All configuration files have exact YAML schemas

---

## Change History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-04-22 | KubeMind Team | Initial definitive technology stack |