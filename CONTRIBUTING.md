# Contributing to KubeMind

## Development Setup

### Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Python | 3.11+ | `pyenv install 3.11` |
| Go | 1.22+ | Download from go.dev |
| Docker | 26.1+ | Docker Desktop |
| kubectl | 1.29+ | `brew install kubectl` |
| Helm | 3.14+ | `brew install helm` |

### Initial Setup

```bash
git clone https://github.com/kubemind/kubemind.git
cd kubemind

# Python setup
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Go setup
go mod download

# Verify
make test
```

---

## Development Workflow

### Branch Naming

```
feature/<feature-name>    # New features
fix/<bug-name>            # Bug fixes
docs/<doc-name>           # Documentation
refactor/<component>      # Refactoring
```

### Commit Convention

```
<type>: <description>

Types:
- feat:     New feature
- fix:      Bug fix
- docs:     Documentation
- refactor: Code refactoring
- test:     Test changes
- chore:    Build/maintenance
```

### Pull Request Process

1. Create branch from `main`
2. Implement changes following RFC specs
3. Add tests
4. Run `make lint && make test`
5. Submit PR with description

---

## Code Standards

### Python

```bash
# Lint
ruff check pkg/

# Format
black pkg/

# Type check
mypy pkg/
```

**Standards**:
- Follow TECH-STACK.md for package imports
- Use Pydantic models for all data structures
- Use exact field names from RFC documents
- Async functions for I/O operations

### Go

```bash
# Lint
golangci-lint run ./pkg/...

# Format
go fmt ./pkg/...
```

**Standards**:
- Follow Go standard project layout
- Use controller-runtime patterns for K8s operations
- Error handling with explicit returns

---

## Testing

### Python Tests

```bash
pytest tests/python/unit/ -v
pytest tests/python/integration/ -v
```

### Go Tests

```bash
go test ./pkg/... -v
```

### Coverage Requirements

| Component | Minimum Coverage |
|-----------|------------------|
| Agents | 80% |
| Knowledge Base | 80% |
| Controller | 70% |
| Safety Validator | 90% |

---

## Documentation

### RFC Updates

When modifying architecture:
1. Update corresponding RFC document
2. Ensure TECH-STACK.md consistency
3. Update code to match RFC

### Code Comments

- Document public functions
- Explain non-obvious logic
- Reference RFC sections where applicable

---

## Code Review Checklist

### Reviewer

- [ ] Follows RFC specifications
- [ ] Uses TECH-STACK.md package versions
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No hardcoded secrets

---

## Release Process

1. Update ROADMAP.md
2. Update version in files
3. Create release PR
4. Merge after approval
5. Tag release

---

## Questions?

- GitHub Issues: Technical questions
- GitHub Discussions: General discussion

---

## License

By contributing, you agree that your contributions will be licensed under Apache 2.0.