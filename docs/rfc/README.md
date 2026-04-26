# KubeMind RFC (Request for Comments) Documents

This directory contains architecture design and technical specification documents for the KubeMind project. All RFCs must conform to [TECH-STACK.md](../TECH-STACK.md) specifications.

---

## RFC Status

| Status | Description |
|--------|-------------|
| **Draft** | Draft stage, under discussion |
| **Active** | Approved and being implemented |
| **Deprecated** | No longer used |
| **Superseded** | Replaced by new RFC |

---

## RFC Index

### Core Architecture

| RFC | Title | Status | Tech Stack |
|-----|-------|--------|------------|
| [RFC-000](./RFC-000-kubemind-architecture.md) | KubeMind Overall Architecture | Active | Python + Go |

### Layer 1: Human-Machine Interface Layer (Python/FastAPI)

| RFC | Title | Status | Packages |
|-----|-------|--------|----------|
| [RFC-001](./RFC-001-human-machine-interface.md) | Human-Machine Interface Overview | Active | FastAPI, React |
| [RFC-001-1](./RFC-001-1-natural-language-interface.md) | Natural Language Interface | Active | LangChain |
| [RFC-001-2](./RFC-001-2-governance-policy-declaration.md) | Governance Policy Declaration | Active | Pydantic |
| [RFC-001-3](./RFC-001-3-observability-dashboard.md) | Observability Dashboard | Active | FastAPI WebSocket |

### Layer 2: Agent Orchestration Brain Layer (Python/LangChain)

| RFC | Title | Status | Packages |
|-----|-------|--------|----------|
| [RFC-002](./RFC-002-agent-orchestration-brain.md) | Agent Orchestration Brain Overview | Active | LangGraph, LangChain |
| [RFC-002-1](./RFC-002-1-agent-coordinator.md) | Agent Coordinator | Active | LangGraph |
| [RFC-002-2](./RFC-002-2-cluster-planner-agent.md) | Cluster Planner Agent | Draft | LangChain |
| [RFC-002-3](./RFC-002-3-scheduler-governor-agent.md) | Scheduler Governor Agent | Draft | LangChain, stable-baselines3 |
| [RFC-002-4](./RFC-002-4-resource-governor-agent.md) | Resource Governor Agent | Draft | LangChain, prophet |
| [RFC-002-5](./RFC-002-5-network-governor-agent.md) | Network Governor Agent | Draft | LangChain |
| [RFC-002-6](./RFC-002-6-storage-governor-agent.md) | Storage Governor Agent | Draft | LangChain |
| [RFC-002-7](./RFC-002-7-security-governor-agent.md) | Security Governor Agent | Draft | LangChain |
| [RFC-002-8](./RFC-002-8-fault-healer-agent.md) | Fault Healer Agent | Draft | LangChain, torch |
| [RFC-002-9](./RFC-002-9-multi-cluster-agent.md) | Multi-Cluster Agent | Draft | LangChain |

### Layer 3: K8S Knowledge Base Layer (Python/LlamaIndex)

| RFC | Title | Status | Packages |
|-----|-------|--------|----------|
| [RFC-003](./RFC-003-knowledge-base.md) | Knowledge Base Overview | Active | LlamaIndex, Neo4j, PostgreSQL |
| [RFC-003-1](./RFC-003-1-k8s-best-practices-rag.md) | K8S Best Practices Knowledge (RAG) | Active | LlamaIndex, ChromaDB |
| [RFC-003-2](./RFC-003-2-cluster-state-knowledge-graph.md) | Cluster State Knowledge Graph | Active | Neo4j driver |
| [RFC-003-3](./RFC-003-3-historical-decision-database.md) | Historical Decision Database | Active | PostgreSQL, TimescaleDB |

### Layer 4: Execution & Observation Layer (Go/controller-runtime)

| RFC | Title | Status | Packages |
|-----|-------|--------|----------|
| [RFC-004](./RFC-004-execution-observation.md) | Execution & Observation Overview | Active | controller-runtime, client-go |

---

## Reading Order

```
1. TECH-STACK.md → Understand definitive technology choices
2. RFC-000 → Understand overall architecture
3. Layer RFCs (001-004) → Understand layer designs
4. Module RFCs → Understand specific implementations
```

---

## RFC Writing Guidelines

### Required Sections

| Section | Purpose |
|---------|---------|
| Abstract | Brief summary of purpose |
| Detailed Design | Architecture, interfaces, data structures |
| Data Models | Exact Pydantic/Go struct definitions |
| API Specification | REST/gRPC endpoint definitions |
| Performance Targets | Quantitative performance requirements |
| References | External documentation links |

### Code Standards

All RFC code must:
- Use exact package versions from TECH-STACK.md
- Follow TECH-STACK.md directory structure
- Use Pydantic models for Python data structures
- Use Go structs for Go data structures
- Include exact field names and types

### Example Pydantic Model

```python
from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Dict, Any, Optional

class AgentDecision(BaseModel):
    """RFC-002 AgentDecision model - MUST match TECH-STACK.md"""
    decision_id: str = Field(..., min_length=1, max_length=64)
    agent_id: str = Field(..., min_length=1, max_length=64)
    timestamp: datetime
    action_type: str
    action_params: Dict[str, Any]
    confidence: float = Field(..., ge=0.0, le=1.0)
```

### Example Go Struct

```go
// AgentDecision - RFC-002 model
// MUST match TECH-STACK.md specifications
type AgentDecision struct {
    DecisionID    string    `json:"decision_id" validate:"required,min=1,max=64"`
    AgentID       string    `json:"agent_id" validate:"required,min=1,max=64"`
    Timestamp     time.Time `json:"timestamp"`
    ActionType    string    `json:"action_type" validate:"required"`
    Confidence    float64   `json:"confidence" validate:"min=0,max=1"`
}
```

---

## Verification Checklist

Before submitting RFC:
- [ ] Uses packages from TECH-STACK.md
- [ ] Versions match TECH-STACK.md requirements
- [ ] Directory paths match TECH-STACK.md structure
- [ ] Data structures use exact field names
- [ ] Performance targets are quantified

---

## Contributing

1. Ensure TECH-STACK.md compliance
2. Create/update RFC document
3. Submit Pull Request
4. Participate in review

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [TECH-STACK.md](../TECH-STACK.md) | Definitive technology decisions |
| [ROADMAP.md](../ROADMAP.md) | Development milestones |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution guidelines |

---

## Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-04-22 | KubeMind Team | Added TECH-STACK.md compliance |