# RFC-001-1: Natural Language Interface

## Abstract

This document describes the design of the Natural Language Interface (NLI) component in KubeMind, which enables users to interact with Kubernetes clusters through natural language commands and queries.

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

### Core Components

#### 1. Intent Recognition

**Intent Taxonomy**:

```yaml
intents:
  cluster_management:
    - cluster_status
    - cluster_analyze
    - cluster_plan
    - cluster_upgrade
    
  resource_management:
    - resource_list
    - resource_describe
    - resource_create
    - resource_delete
    - resource_scale
    - resource_optimize
    
  troubleshooting:
    - diagnose_pod
    - diagnose_node
    - diagnose_performance
    - diagnose_network
    
  security:
    - security_check
    - rbac_query
    - rbac_generate
    - vulnerability_scan
    
  capacity_planning:
    - predict_resources
    - capacity_status
    - capacity_recommend
    
  multi_cluster:
    - cluster_compare
    - workload_migrate
    - disaster_recovery
    
  general:
    - help
    - explain
    - suggest
    - feedback
```

**Intent Classification Prompt**:

```python
INTENT_CLASSIFICATION_PROMPT = """
You are an intent classifier for Kubernetes cluster management.

Given a user query, classify it into one of the following intents:
{intent_list}

User query: {user_query}

Output format:
{
    "intent": "<intent_name>",
    "confidence": <float between 0 and 1>,
    "reasoning": "<brief explanation>"
}
"""
```

#### 2. Entity Extraction

**Entity Types**:

```yaml
entities:
  resources:
    - pod
    - deployment
    - service
    - node
    - namespace
    - configmap
    - secret
    - pv/pvc
    
  identifiers:
    - resource_name
    - namespace_name
    - cluster_name
    - label_selector
    
  values:
    - replica_count
    - version
    - port
    - cpu/memory_limit
    - storage_size
    
  time:
    - duration
    - timestamp
    - schedule
    
  boolean:
    - enable/disable
    - force
    - dry_run
```

#### 3. Context Manager

**Context Structure**:

```python
@dataclass
class ConversationContext:
    session_id: str
    current_cluster: str
    current_namespace: str
    focus_resource: Optional[ResourceReference]
    recent_intents: List[str]
    entity_memory: Dict[str, Any]
    user_preferences: Dict[str, Any]
    temporal_context: Dict[str, Any]
```

**Context Management Rules**:

```yaml
context_rules:
  namespace_inheritance:
    description: "If namespace mentioned in turn N, use it in turn N+1 if not specified"
    example:
      - turn_1: "List pods in production namespace"
      - turn_2: "Scale nginx to 5 replicas"
      - resolved_namespace: "production"
      
  resource_focus:
    description: "Focus on resource mentioned in last turn"
    example:
      - turn_1: "Describe pod api-server-123"
      - turn_2: "Why is it crashing?"
      - resolved_resource: "pod/api-server-123"
```

#### 4. Command Generator

**Command Templates**:

```yaml
templates:
  resource_scale:
    kubectl: "kubectl scale deployment/{name} --replicas={count} -n {namespace}"
    api:
      method: PATCH
      path: "/apis/apps/v1/namespaces/{namespace}/deployments/{name}/scale"
      body:
        spec:
          replicas: {count}
          
  resource_list:
    kubectl: "kubectl get {resource_type} -n {namespace}"
    api:
      method: GET
      path: "/api/v1/namespaces/{namespace}/{resource_type}"
```

#### 5. Response Generator

**Response Generation Prompt**:

```python
RESPONSE_GENERATION_PROMPT = """
You are explaining Kubernetes operations to a user.

Intent: {intent}
Entities: {entities}
Action taken: {action}
Results: {results}

Generate a response that:
1. Acknowledges what the user asked
2. Explains what action was taken
3. Shows the results clearly
4. Provides relevant context or insights
5. Suggests follow-up actions

Response format:
{
    "acknowledgment": "<what user asked>",
    "action_taken": "<what was done>",
    "results": "<outcome>",
    "insights": "<relevant insights>",
    "recommendations": ["<list of recommendations>"],
    "follow_up": ["<list of follow-up suggestions>"]
}
"""
```

### Interaction Patterns

#### Pattern 1: Direct Command

```
User: "Scale deployment nginx to 5 replicas in production namespace"
System: 
  "I've scaled the nginx deployment in production namespace to 5 replicas.
  
  Previous: 3 replicas
  Current: 5 replicas
  
  The deployment is now rolling out the new replicas. This should complete in approximately 2 minutes.
  
  Recommendations:
  - Monitor pod health during rollout
  - Check resource utilization after scaling"
```

#### Pattern 2: Multi-Turn Query

```
Turn 1:
User: "How many pods are in the production namespace?"
System: "There are 42 pods running in production namespace."
Context: namespace="production", intent="resource_list"

Turn 2:
User: "Show me the ones with high CPU usage"
System: "3 pods have high CPU usage (>80%): api-server, worker-1, worker-2"
Context: namespace="production", focus="high_cpu_pods"

Turn 3:
User: "Scale api-server to handle the load"
System: "Scaling api-server deployment to 8 replicas in production namespace."
Context: namespace="production", resource="api-server"
```

### Performance Considerations

```yaml
performance:
  caching:
    - intent_cache: 1 minute TTL
    - entity_cache: session-based
    - response_template_cache: 1 hour TTL
    
  streaming:
    - Stream LLM response for long explanations
    - Progressive rendering for complex results
    
  quality:
    confidence_threshold: 0.7
    fallback:
      - If confidence < 0.7, ask clarifying questions
      - If intent ambiguous, show options
```

## References

- [LangChain Conversation Patterns](https://python.langchain.com/docs/)
- [Intent Recognition Best Practices](https://arxiv.org/)

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-04-21 | KubeMind Team | Initial version |