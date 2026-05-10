# RFC-003-3: Historical Decision Database

## Abstract

This document describes the historical decision database for storing and querying past decisions and outcomes.

## Detailed Design

### Database Schema

#### Data Model: decisions Table

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `decision_id` | VARCHAR | PRIMARY KEY | Unique identifier for the decision |
| `agent_id` | VARCHAR | NOT NULL | Identifier of the agent that made the decision |
| `decision_type` | VARCHAR | NOT NULL | Category/type of the decision |
| `timestamp` | TIMESTAMP | NOT NULL | Time when decision was made |
| `reasoning` | TEXT | Optional | Explanation of the decision rationale |
| `outcome` | VARCHAR | Optional | Result classification of the decision |
| `success` | BOOLEAN | Optional | Whether the decision led to successful outcome |
| `context` | JSONB | Optional | JSON context data for the decision |

#### Data Model: outcomes Table

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `decision_id` | VARCHAR | FOREIGN KEY (decisions) | Reference to the parent decision |
| `outcome_type` | VARCHAR | Optional | Classification of the outcome |
| `outcome_data` | JSONB | Optional | JSON data containing outcome details |
| `timestamp` | TIMESTAMP | Optional | Time when outcome was recorded |

### Query Patterns

#### Function Specification: get_similar_decisions

| Aspect | Description |
|--------|-------------|
| **Function** | `get_similar_decisions` |
| **Purpose** | Retrieve historical decisions matching a given context |

**Input Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `context` | Dict | Dictionary containing decision type and context data |

**Process Steps:**

| Step | Operation | Description |
|------|-----------|-------------|
| 1 | Filter by decision type | Match records where `decision_type` equals context type |
| 2 | JSON context matching | Use JSON containment operator to match context structure |
| 3 | Sort by timestamp | Order results by most recent first |
| 4 | Limit results | Return top 10 matching decisions |

**Output:**

| Type | Description |
|------|-------------|
| `List[Decision]` | List of similar historical decisions |

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |
| 1.1.0 | 2026-04-26 | KubeMind Team | Convert code to specification design |