# RFC-003-3: Historical Decision Database

## Abstract

This document describes the historical decision database for storing and querying past decisions and outcomes.

## Detailed Design

### Database Schema

```sql
CREATE TABLE decisions (
    decision_id VARCHAR PRIMARY KEY,
    agent_id VARCHAR NOT NULL,
    decision_type VARCHAR NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    reasoning TEXT,
    outcome VARCHAR,
    success BOOLEAN,
    context JSONB
);

CREATE TABLE outcomes (
    decision_id VARCHAR REFERENCES decisions,
    outcome_type VARCHAR,
    outcome_data JSONB,
    timestamp TIMESTAMP
);
```

### Query Patterns

```python
def get_similar_decisions(context: Dict) -> List[Decision]:
    return db.query("""
        SELECT * FROM decisions
        WHERE decision_type = :type
        AND context::jsonb @> :context::jsonb
        ORDER BY timestamp DESC
        LIMIT 10
    """, {'type': context['type'], 'context': context})
```

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |