.PHONY: help setup install clean dev build test deploy status logs

# Default target
help:
	@echo "AssureX Development Workspace"
	@echo "=============================="
	@echo ""
	@echo "Available commands:"
	@echo "  make setup        - Initial workspace setup (clone repos, install dependencies)"
	@echo "  make install      - Install dependencies for both frontend and backend"
	@echo "  make dev          - Start local development environment (docker-compose)"
	@echo "  make dev-frontend - Run frontend development server only"
	@echo "  make dev-backend  - Run backend services (localstack, postgres)"
	@echo "  make build        - Build both frontend and backend"
	@echo "  make test         - Run tests for both projects"
	@echo "  make deploy-dev   - Deploy backend to AWS dev environment"
	@echo "  make deploy-preprod - Deploy backend to AWS preprod environment"
	@echo "  make status       - Check status of both repositories"
	@echo "  make logs         - Show docker-compose logs"
	@echo "  make clean        - Clean build artifacts and dependencies"
	@echo ""

# Initial workspace setup
setup:
	@echo "Setting up AssureX workspace..."
	@if [ ! -d "trustx" ]; then \
		echo "Cloning trustx frontend repository..."; \
		git clone git@github.com:TrustXinc/trustx.git; \
	fi
	@if [ ! -d "assurex-infra" ]; then \
		echo "Cloning assurex-infra backend repository..."; \
		git clone git@github.com:TrustXinc/assurex-infra.git; \
	fi
	@make install
	@echo "✅ Workspace setup complete!"

# Install all dependencies
install:
	@echo "Installing dependencies..."
	@echo "→ Frontend dependencies..."
	cd trustx && npm install
	@echo "→ Backend Lambda dependencies..."
	cd assurex-infra/resources/lambda-functions/integrations-configure && npm install
	@echo "✅ Dependencies installed!"

# Start full development environment with docker-compose
dev:
	@echo "Starting AssureX development environment..."
	docker-compose up

# Start development services in background
dev-bg:
	@echo "Starting AssureX development environment (background)..."
	docker-compose up -d
	@echo "✅ Services running in background"
	@echo "   Frontend: http://localhost:3000"
	@echo "   PostgreSQL: localhost:5432"
	@echo "   LocalStack: http://localhost:4566"

# Stop development environment
dev-stop:
	@echo "Stopping development environment..."
	docker-compose down

# Run frontend development server only
dev-frontend:
	@echo "Starting frontend development server..."
	cd trustx && npm run dev

# Run backend services only (postgres + localstack)
dev-backend:
	@echo "Starting backend services..."
	docker-compose up postgres localstack

# Build both projects
build:
	@echo "Building AssureX projects..."
	@echo "→ Building frontend..."
	cd trustx && npm run build
	@echo "→ Building backend Lambda layers..."
	cd assurex-infra/resources/lambda-layers/db-connector && ./build-layer.sh
	@echo "✅ Build complete!"

# Run all tests
test:
	@echo "Running tests..."
	@echo "→ Frontend tests..."
	cd trustx && npm run test
	@echo "→ Backend tests..."
	cd assurex-infra && npm run test
	@echo "✅ All tests passed!"

# Deploy to AWS dev environment
deploy-dev:
	@echo "Deploying to AWS dev environment..."
	cd assurex-infra/resources/lambda-functions/integrations-configure && \
		serverless deploy --stage dev --region us-east-1
	@echo "✅ Deployed to dev!"

# Deploy to AWS preprod environment
deploy-preprod:
	@echo "Deploying to AWS preprod environment..."
	cd assurex-infra/resources/lambda-functions/integrations-configure && \
		serverless deploy --stage preprod --region us-east-2
	@echo "✅ Deployed to preprod!"

# Check git status of both repos
status:
	@echo "Repository Status"
	@echo "================="
	@echo ""
	@echo "Frontend (trustx):"
	@echo "-------------------"
	cd trustx && git status -s
	@echo ""
	@echo "Backend (assurex-infra):"
	@echo "-------------------------"
	cd assurex-infra && git status -s
	@echo ""

# Show docker-compose logs
logs:
	docker-compose logs -f

# Show logs for specific service
logs-frontend:
	docker-compose logs -f frontend

logs-postgres:
	docker-compose logs -f postgres

logs-localstack:
	docker-compose logs -f localstack

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@echo "→ Frontend..."
	cd trustx && rm -rf .next node_modules
	@echo "→ Backend..."
	cd assurex-infra && find . -type d -name ".serverless" -exec rm -rf {} + || true
	cd assurex-infra && find . -type d -name "node_modules" -exec rm -rf {} + || true
	cd assurex-infra && find . -type d -name "__pycache__" -exec rm -rf {} + || true
	@echo "→ Docker volumes..."
	docker-compose down -v
	@echo "✅ Cleaned!"

# Pull latest changes from both repos
pull:
	@echo "Pulling latest changes..."
	@echo "→ Frontend..."
	cd trustx && git pull origin main
	@echo "→ Backend..."
	cd assurex-infra && git pull origin main
	@echo "✅ Repositories updated!"

# Show current branch for both repos
branches:
	@echo "Current Branches"
	@echo "================"
	@echo ""
	@echo -n "Frontend: "
	@cd trustx && git branch --show-current
	@echo -n "Backend: "
	@cd assurex-infra && git branch --show-current
	@echo ""
