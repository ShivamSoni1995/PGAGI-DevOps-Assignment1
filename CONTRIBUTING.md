# Contributing Guidelines

Thank you for your interest in contributing to this project!

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Set up the development environment
4. Create a feature branch

## Development Workflow

1. Create a branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and write tests

3. Run tests locally:
   ```bash
   # Backend tests
   cd backend && pytest -v

   # Frontend tests
   cd frontend && npm run test:e2e
   ```

4. Commit with meaningful messages:
   ```bash
   git commit -m "feat(backend): add new endpoint for messages"
   ```

5. Push and create a Pull Request to `develop`

## Commit Message Format

We follow conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(api): add message deletion endpoint
fix(frontend): resolve connection timeout issue
docs(readme): update deployment instructions
test(backend): add unit tests for health check
```

## Code Standards

### Backend (Python)
- Follow PEP 8
- Use type hints
- Write docstrings for functions
- Maintain test coverage > 80%

### Frontend (JavaScript)
- Follow ESLint rules
- Use meaningful variable names
- Write E2E tests for new features

### Terraform
- Use consistent naming conventions
- Add descriptions to variables
- Document complex configurations

## Pull Request Process

1. Update documentation if needed
2. Add/update tests for your changes
3. Ensure CI pipeline passes
4. Request review from maintainers
5. Address review feedback
6. Squash commits before merge

## Questions?

Open an issue for any questions or concerns.
