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
| [RFC-000](./RFC-000-kubemind-architecture.md) | KubeMind Intent-Driven Architecture | Active | Python + Go |

### Intent Definition & Translation (Layer 1-2)

| RFC | Title | Status | Packages |
|-----|-------|--------|----------|
| [RFC-001](./RFC-001-human-machine-interface.md) | Intent Interface Layer | Active | FastAPI, LangChain |
| [RFC-001-1](./RFC-001-1-natural-language-interface.md) | Natural Language Interface | Active | LangChain |
| [RFC-001-2](./RFC-001-2-governance-policy-declaration.md) | Governance Policy Declaration | Active | Pydantic |
| [RFC-001-3](./RFC-001-3-observability-dashboard.md) | Intent Visualization Dashboard | Active | FastAPI WebSocket |
| [RFC-005](./RFC-005-system-intent-declaration.md) | System Intent Declaration (SID) Schema | Active | Pydantic |
| [RFC-006](./RFC-006-knowledge-injection-interface.md) | Knowledge Injection Interface (KII) | Active | Pydantic |
| [RFC-007](./RFC-007-universal-intent-translator.md) | Universal Intent Translator (UIT) | Active | LangChain |

### Layer 2: Autonomous Governance Brain (Python/LangChain)

| RFC | Title | Status | Packages |
|-----|-------|--------|----------|
| [RFC-002](./RFC-002-agent-orchestration-brain.md) | Autonomous Governance Brain Overview | Active | LangGraph, LangChain |
| [RFC-002-1](./RFC-002-1-agent-coordinator.md) | Agent Coordinator | Active | LangGraph |
| [RFC-002-2](./RFC-002-2-cluster-planner-agent.md) | Cluster Planner Agent | Draft | LangChain |
| [RFC-002-3](./RFC-002-3-scheduler-governor-agent.md) | Scheduler Governor Agent | Draft | LangChain, stable-baselines3 |
| [RFC-002-4](./RFC-002-4-resource-governor-agent.md) | Resource Governor Agent | Draft | LangChain, prophet |
| [RFC-002-5](./RFC-002-5-network-governor-agent.md) | Network Governor Agent | Draft | LangChain |
| [RFC-002-6](./RFC-002-6-storage-governor-agent.md) | Storage Governor Agent | Draft | LangChain |
| [RFC-002-7](./RFC-002-7-security-governor-agent.md) | Security Governor Agent | Draft | LangChain |
| [RFC-002-8](./RFC-002-8-fault-healer-agent.md) | Fault Healer Agent | Draft | LangChain, torch |
| [RFC-002-9](./RFC-002-9-multi-cluster-agent.md) | Multi-Cluster Agent | Draft | LangChain |

### Layer 3: Knowledge Base Layer (Python/LlamaIndex)

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
2. RFC-000 → Understand intent-driven architecture
3. RFC-005 → Understand System Intent Declaration schema
4. RFC-006 → Understand Knowledge Injection interface
5. RFC-007 → Understand Intent Translation process
6. Layer RFCs (001-004) → Understand layer designs
7. Module RFCs → Understand specific implementations
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

class SystemIntentDeclaration(BaseModel):
    """RFC-005 SID model - MUST match TECH-STACK.md"""
    intent_id: str = Field(..., min_length=1, max_length=64)
    natural_language: str = Field(..., min_length=10)
    specification: SpecificationIntent
    behavior: BehaviorIntent
    constraints: Optional[ConstraintIntent] = None
    deployment: DeploymentIntent
```

### Example Go Struct

```go
// SystemIntentDeclaration - RFC-005 model
// MUST match TECH-STACK.md specifications
type SystemIntentDeclaration struct {
    IntentID        string             `json:"intent_id" validate:"required,min=1,max=64"`
    NaturalLanguage string             `json:"natural_language" validate:"required,min=10"`
    Specification   SpecificationIntent `json:"specification"`
    Behavior        BehaviorIntent      `json:"behavior"`
    Deployment      DeploymentIntent    `json:"deployment"`
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
| [VISION.md](../VISION.md) | Intent-driven vision |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution guidelines |

---

## Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0.0 | 2026-04-26 | KubeMind Team | Intent-driven architecture update, added RFC-005/006/007 |
| 1.0.0 | 2026-04-22 | KubeMind Team | Added TECH-STACK.md compliance |