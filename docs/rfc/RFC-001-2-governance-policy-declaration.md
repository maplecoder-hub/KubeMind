# RFC-001-2: Governance Policy Declaration

## Abstract

This document describes the design of the Governance Policy Declaration system in KubeMind, which enables users to define cluster governance policies in a declarative manner. This system will be replaced by System Intent Declaration (SID) in the intent-driven architecture.

## Detailed Design

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│           Governance Policy Declaration System               │
├────────────────────────────────────────────────────────────┤
│  Policy Input Sources                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ YAML File    │  │ Natural      │  │ Web UI       │     │
│  │ Upload       │  │ Language     │  │ Editor       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│           └────────────────┼──────────────────┘            │
│                           ↓                                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Policy Processing Engine                 │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Policy       │  │ Validation   │                │  │
│  │  │ Parser       │  │ Engine       │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Conflict     │  │ Policy       │                │  │
│  │  │ Detector     │  │ Generator    │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  └─────────────────────────────────────────────────────┘  │
│                           ↓                                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Policy Lifecycle Manager                 │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Version      │  │ Approval     │                │  │
│  │  │ Control      │  │ Workflow     │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Rollback     │  │ Policy       │                │  │
│  │  │ Manager      │  │ Analytics    │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

---

### Policy Types Specification

| Policy Type | Description | Scope | Intent Equivalent |
|-------------|-------------|-------|-------------------|
| ClusterGovernancePolicy | Cluster-wide governance policy | cluster | Specification Intent + Behavior Intent |
| NamespaceGovernancePolicy | Namespace-level governance policy | namespace | Specification Intent |
| SecurityPolicy | Security and compliance policy | cluster/namespace | Constraint Intent (security) |
| SchedulingPolicy | Scheduling optimization policy | cluster | Behavior Intent (performance) |
| FaultHandlingPolicy | Fault detection and healing policy | cluster/namespace | Behavior Intent (resilience) |

---

### Policy DSL Specification

#### ClusterGovernancePolicy Spec

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| apiVersion | string | Yes | kubemind.ai/v1alpha1 |
| kind | string | Yes | ClusterGovernancePolicy |
| metadata.name | string | Yes | Policy name |
| metadata.labels | dict | No | Policy labels |
| spec.scheduling.mode | enum | No | Mode: intelligent, manual |
| spec.scheduling.algorithm | enum | No | Algorithm: reinforcement-learning, heuristic |
| spec.scheduling.objectives | list[Objective] | No | Scheduling objectives |
| spec.resources.autoQuota | boolean | No | Auto quota generation |
| spec.resources.capacityPlanning.enabled | boolean | No | Enable capacity planning |
| spec.security.rbac.generation | enum | No | RBAC generation: auto, manual |
| spec.security.compliance.frameworks | list[enum] | No | Compliance frameworks |
| spec.faultHandling.mode | enum | No | Mode: predictive, reactive |
| spec.faultHandling.autoHealing.enabled | boolean | No | Enable auto healing |
| spec.approval.required | list[string] | No | Required approval actions |

#### Scheduling Objective Specification

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Objective name |
| weight | float (0-1) | Yes | Objective weight |
| target | float | No | Objective target value |

---

### Policy Validation

#### Validation Rules Specification

| Validation Type | Rules | Description |
|-----------------|-------|-------------|
| **Structural Validation** | required_fields_check, type_validation, enum_value_check | Basic structure validation |
| **Semantic Validation** | weight_sum_equals_one, valid_reference_check, target_value_range | Semantic correctness |
| **Constraint Validation** | resource_constraint, node_constraint, network_constraint | Constraint feasibility |
| **Security Validation** | rbac_least_privilege, no_privileged_containers | Security compliance |

#### Validation Process

| Step | Input | Process | Output |
|------|-------|---------|--------|
| 1 | Policy YAML | Structure validation | Structural validation result |
| 2 | Validated policy | Semantic validation | Semantic validation result |
| 3 | Validated policy + Cluster state | Constraint validation | Constraint validation result |
| 4 | Validated policy | Security validation | Security validation result |
| 5 | Validated policy | Compliance validation | Compliance validation result |

#### Validation Result Specification

| Field | Type | Description |
|-------|------|-------------|
| valid | boolean | Overall validation status |
| errors | list[ValidationError] | Validation errors |
| warnings | list[ValidationWarning] | Validation warnings |

---

### Conflict Detection

#### Conflict Types Specification

| Conflict Type | Description | Detection Method |
|---------------|-------------|------------------|
| Scope Conflict | Policies at different scopes have conflicting rules | Scope hierarchy check |
| Priority Conflict | Multiple policies with same priority contradict | Priority comparison |
| Resource Conflict | Resource allocation conflicts | Resource overlap check |
| Scheduling Conflict | Scheduling objectives contradict | Objective weight check |

#### Resolution Strategy Specification

| Strategy | Order | Description |
|----------|-------|-------------|
| Explicit Priority | 1 | Policy with explicit higher priority wins |
| Scope Hierarchy | 2 | Cluster policy > Namespace policy |
| Creation Order | 3 | Earlier created policy wins |
| User Choice | 4 | User decides resolution |

#### Automatic Resolution Rules

| Rule | Condition | Resolution |
|------|-----------|------------|
| Security overrides performance | Security policy vs performance policy | Security policy wins |
| Compliance overrides custom | Compliance framework vs custom policy | Compliance policy wins |

---

### Policy Lifecycle Management

#### Version Control Specification

| Feature | Configuration | Description |
|---------|---------------|-------------|
| Storage | Git | Policy version control |
| Operations | create, update, rollback, diff, history | Available operations |
| Versioning Format | SemVer | Semantic versioning |
| Auto Increment | true | Auto increment on update |
| Max Versions | 50 | Maximum retained versions |
| Retention Period | 90d | Version retention period |

#### Approval Workflow Specification

| Step | Name | Actor | Timeout | Auto |
|------|------|-------|---------|------|
| 1 | submit | user | - | No |
| 2 | validate | system | - | Yes |
| 3 | review | approver | 24h | No |
| 4 | apply | system | - | Yes (if approved) |

---

## References

- [Kubernetes API Conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)
- [Policy as Code Best Practices](https://openpolicyagent.org/)

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.1.0 | 2026-04-26 | KubeMind Team | Convert code to specification design |
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |