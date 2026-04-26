.PHONY: all build test lint clean install run docs help

# Variables
PYTHON_VERSION := 3.11
GO_VERSION := 1.22
PROJECT_NAME := kubemind
BUILD_DIR := bin
HELM_DIR := helm/kubemind
TEST_DIR := tests

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m

all: lint test build

## ============================================================================
## Build
## ============================================================================

build: build-python build-go
	@echo "$(GREEN)✓ Build complete$(NC)"

build-python:
	@echo "$(BLUE)Building Python packages...$(NC)"
	python -m pip install --upgrade pip build wheel
	python -m build

build-go:
	@echo "$(BLUE)Building Go binaries...$(NC)"
	mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/kubemind ./cmd/kubemind
	go build -o $(BUILD_DIR)/controller ./cmd/controller

build-cli:
	@echo "$(BLUE)Building CLI...$(NC)"
	go build -o $(BUILD_DIR)/kubemind ./cmd/kubemind

build-controller:
	@echo "$(BLUE)Building Controller...$(NC)"
	go build -o $(BUILD_DIR)/controller ./cmd/controller

build-dashboard:
	@echo "$(BLUE)Building Dashboard Backend...$(NC)"
	cd pkg/dashboard && python -m pip install -e .

build-web:
	@echo "$(BLUE)Building Web Frontend...$(NC)"
	cd web && npm install && npm run build

## ============================================================================
## Test
## ============================================================================

test: test-python test-go
	@echo "$(GREEN)✓ All tests passed$(NC)"

test-python:
	@echo "$(BLUE)Running Python tests...$(NC)"
	pytest tests/python/ -v --cov=pkg --cov-report=term-missing

test-go:
	@echo "$(BLUE)Running Go tests...$(NC)"
	go test ./pkg/... -v -coverprofile=coverage.out

test-unit:
	@echo "$(BLUE)Running unit tests...$(NC)"
	pytest tests/python/unit/ -v
	go test ./pkg/... -short -v

test-integration:
	@echo "$(BLUE)Running integration tests...$(NC)"
	pytest tests/python/integration/ -v
	go test ./tests/go/integration/... -v

## ============================================================================
## Lint
## ============================================================================

lint: lint-python lint-go
	@echo "$(GREEN)✓ All lint checks passed$(NC)"

lint-python:
	@echo "$(BLUE)Linting Python code...$(NC)"
	ruff check pkg/ tests/
	mypy pkg/

lint-go:
	@echo "$(BLUE)Linting Go code...$(NC)"
	golangci-lint run ./pkg/...

format: format-python format-go
	@echo "$(GREEN)✓ Code formatted$(NC)"

format-python:
	@echo "$(BLUE)Formatting Python code...$(NC)"
	black pkg/ tests/
	ruff format pkg/ tests/

format-go:
	@echo "$(BLUE)Formatting Go code...$(NC)"
	go fmt ./pkg/...

## ============================================================================
## Development
## ============================================================================

install:
	@echo "$(BLUE)Installing dependencies...$(NC)"
	pip install -r requirements.txt
	pip install -r requirements-dev.txt
	go mod download

run:
	@echo "$(BLUE)Starting KubeMind...$(NC)"
	python -m pkg.dashboard.app

run-cli:
	@echo "$(BLUE)Starting CLI...$(NC)"
	./$(BUILD_DIR)/kubemind

run-controller:
	@echo "$(BLUE)Starting Controller...$(NC)"
	./$(BUILD_DIR)/controller --kubeconfig=${KUBECONFIG}

## ============================================================================
## Docker
## ============================================================================

docker-build:
	@echo "$(BLUE)Building Docker images...$(NC)"
	docker build -t $(PROJECT_NAME):latest .
	docker build -t $(PROJECT_NAME)-controller:latest -f Dockerfile.controller .

docker-push:
	@echo "$(BLUE)Pushing Docker images...$(NC)"
	docker push $(PROJECT_NAME):latest
	docker push $(PROJECT_NAME)-controller:latest

docker-compose-up:
	@echo "$(BLUE)Starting with Docker Compose...$(NC)"
	docker-compose up -d

docker-compose-down:
	@echo "$(BLUE)Stopping Docker Compose...$(NC)"
	docker-compose down

## ============================================================================
## Kubernetes
## ============================================================================

helm-install:
	@echo "$(BLUE)Installing Helm chart...$(NC)"
	helm install $(PROJECT_NAME) $(HELM_DIR) \
		--namespace $(PROJECT_NAME)-system \
		--create-namespace

helm-uninstall:
	@echo "$(BLUE)Uninstalling Helm chart...$(NC)"
	helm uninstall $(PROJECT_NAME) --namespace $(PROJECT_NAME)-system

helm-template:
	@echo "$(BLUE)Generating Helm templates...$(NC)"
	helm template $(PROJECT_NAME) $(HELM_DIR)

kubectl-apply:
	@echo "$(BLUE)Applying manifests...$(NC)"
	kubectl apply -f manifests/

kubectl-delete:
	@echo "$(BLUE)Deleting manifests...$(NC)"
	kubectl delete -f manifests/

## ============================================================================
## Documentation
## ============================================================================

docs:
	@echo "$(BLUE)Building documentation...$(NC)"
	cd docs && mkdocs serve

docs-build:
	@echo "$(BLUE)Building documentation...$(NC)"
	cd docs && mkdocs build

## ============================================================================
## Clean
## ============================================================================

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR)
	rm -rf dist
	rm -rf build
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf coverage.out
	rm -rf htmlcov
	rm -rf .mypy_cache
	rm -rf .ruff_cache
	rm -rf __pycache__
	rm -rf .eggs
	rm -rf *.egg-info
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete

## ============================================================================
## CRD Generation
## ============================================================================

generate-crd:
	@echo "$(BLUE)Generating CRD manifests...$(NC)"
	controller-gen crd:crdVersions=v1 \
		paths=./api/crd/... \
		output:crd:dir=manifests/crd

generate-deepcopy:
	@echo "$(BLUE)Generating deepcopy functions...$(NC)"
	controller-gen object \
		paths=./api/crd/...

## ============================================================================
## Version
## ============================================================================

version:
	@echo "$(PROJECT_NAME) version: $(shell cat VERSION 2>/dev/null || echo 'unknown')"
	@echo "Python: $(PYTHON_VERSION)"
	@echo "Go: $(GO_VERSION)"

## ============================================================================
## Help
## ============================================================================

help:
	@echo "$(GREEN)KubeMind Makefile$(NC)"
	@echo ""
	@echo "$(BLUE)Usage:$(NC)"
	@echo "  make <target>"
	@echo ""
	@echo "$(BLUE)Targets:$(NC)"
	@echo "  $(YELLOW)Build:$(NC)"
	@echo "    build           Build all components"
	@echo "    build-python    Build Python packages"
	@echo "    build-go        Build Go binaries"
	@echo "    build-cli       Build CLI binary"
	@echo "    build-controller Build Controller binary"
	@echo "    build-web       Build web frontend"
	@echo ""
	@echo "  $(YELLOW)Test:$(NC)"
	@echo "    test            Run all tests"
	@echo "    test-python     Run Python tests"
	@echo "    test-go         Run Go tests"
	@echo "    test-unit       Run unit tests"
	@echo "    test-integration Run integration tests"
	@echo ""
	@echo "  $(YELLOW)Lint:$(NC)"
	@echo "    lint            Run all linters"
	@echo "    lint-python     Run Python linters"
	@echo "    lint-go         Run Go linters"
	@echo "    format          Format all code"
	@echo ""
	@echo "  $(YELLOW)Development:$(NC)"
	@echo "    install         Install dependencies"
	@echo "    run             Start KubeMind"
	@echo "    run-cli         Start CLI"
	@echo "    run-controller  Start Controller"
	@echo ""
	@echo "  $(YELLOW)Docker:$(NC)"
	@echo "    docker-build    Build Docker images"
	@echo "    docker-compose-up Start with compose"
	@echo "    docker-compose-down Stop compose"
	@echo ""
	@echo "  $(YELLOW)Kubernetes:$(NC)"
	@echo "    helm-install    Install Helm chart"
	@echo "    helm-uninstall  Uninstall Helm chart"
	@echo "    kubectl-apply   Apply manifests"
	@echo ""
	@echo "  $(YELLOW)Generation:$(NC)"
	@echo "    generate-crd    Generate CRD manifests"
	@echo "    generate-deepcopy Generate deepcopy"
	@echo ""
	@echo "  $(YELLOW)Other:$(NC)"
	@echo "    clean           Clean build artifacts"
	@echo "    docs            Serve documentation"
	@echo "    version         Show version"
	@echo "    help            Show this help"