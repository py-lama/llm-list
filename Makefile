.PHONY: install test lint format typecheck clean build publish

# Python interpreter
PYTHON = python3
PIP = pip3

# Directories
SRC_DIR = llm_list
TESTS_DIR = tests

# Install the package in development mode
install:
	$(PIP) install -e ".[dev]"

# Install development dependencies
dev:
	$(PIP) install -r requirements-dev.txt

# Run tests
test:
	$(PYTHON) -m pytest -v --cov=$(SRC_DIR) --cov-report=term-missing

# Run tests with coverage report
coverage:
	$(PYTHON) -m pytest --cov=$(SRC_DIR) --cov-report=html
	@echo "Open htmlcov/index.html in your browser to view the coverage report."

# Run linter
lint:
	black --check $(SRC_DIR) $(TESTS_DIR)
	isort --check-only $(SRC_DIR) $(TESTS_DIR)
	mypy $(SRC_DIR) $(TESTS_DIR)
	black $(SRC_DIR) $(TESTS_DIR)
	isort $(SRC_DIR) $(TESTS_DIR)

format-check: ## Check code formatting without making changes
	black --check $(SRC_DIR) $(TESTS_DIR)
	isort --check-only $(SRC_DIR) $(TESTS_DIR)

# Linting
lint: ## Run all linters (black, isort, flake8, mypy)
	black --check $(SRC_DIR) $(TESTS_DIR)
	isort --check-only $(SRC_DIR) $(TESTS_DIR)
	flake8 $(SRC_DIR) $(TESTS_DIR)
	mypy $(SRC_DIR) $(TESTS_DIR)

# Testing
test: ## Run tests with coverage
	$(PYTHON) -m pytest -v --cov=$(SRC_DIR) --cov-report=term-missing

test-html: ## Run tests and generate HTML coverage report
	$(PYTHON) -m pytest --cov=$(SRC_DIR) --cov-report=html

# Building
build: clean ## Build source and wheel packages
	$(PYTHON) -m build

# Publishing
publish-test: build ## Upload to test PyPI
	twine upload --repository testpypi dist/*

publish: build ## Upload to PyPI
	twine upload dist/*

# Cleaning
clean: ## Remove all build, test, coverage and Python artifacts
	rm -rf build/ dist/ *.egg-info .pytest_cache/ .coverage htmlcov/ .mypy_cache/
	find . -type d -name '__pycache__' -exec rm -rf {} +
	find . -type f -name '*.py[co]' -delete

# Docker
docker-build: ## Build Docker image
	docker build -t llm-list .

docker-run: ## Run the Docker container
	docker run --rm -it llm-list

# Documentation
docs: ## Generate documentation
	$(MAKE) -C docs html

# Release
release: clean build publish ## Create and publish a new release

# Check everything
check: lint test ## Run all checks (lint, test, format)

# Default
default: help
