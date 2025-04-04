# Contributing to Dokku EdgeDB Plugin

Thank you for your interest in contributing to the Dokku EdgeDB (Gel) plugin! This document provides guidelines and instructions for contributing.

## Development Environment

### Setting Up for Development

1. **Prerequisites**:
   - Docker (if using the provided development container)
   - Dokku installed locally (optional for full integration testing)
   - Basic knowledge of Bash scripting and Dokku plugin architecture

2. **Fork and Clone**:
   ```bash
   git clone https://github.com/your-username/dokku-edgedb.git
   cd dokku-edgedb
   ```

3. **Testing Environment**:
   The project includes a mock Dokku implementation for testing without a full Dokku installation:
   ```bash
   # Copy mock script
   cp dokku-mock.sh /usr/local/bin/dokku
   chmod +x /usr/local/bin/dokku
   mkdir -p /var/lib/dokku/services/gel
   ```

## Testing

### Mock Testing

For rapid development, we use a mock Dokku implementation that simulates the behavior of Dokku commands. This allows testing without a full Dokku installation.

```bash
# Run specific tests
DOKKU_BIN=/usr/local/bin/dokku PLUGIN_DATA_ROOT=/var/lib/dokku/services/gel bats tests/service_create.bats

# Run all tests
DOKKU_BIN=/usr/local/bin/dokku PLUGIN_DATA_ROOT=/var/lib/dokku/services/gel bats tests/*.bats
```

### Full Integration Testing

For complete integration testing, you need a Dokku installation:

```bash
# Install plugin to dokku
dokku plugin:install https://github.com/your-username/dokku-edgedb.git

# Run tests
cd /var/lib/dokku/plugins/dokku-edgedb
bats tests/*.bats
```

## Code Style and Guidelines

1. **Bash Best Practices**:
   - Use `shellcheck` to lint your Bash scripts
   - Use meaningful variable names and add comments
   - Follow the existing code style

2. **Documentation**:
   - Update README.md with any new commands or features
   - Add command documentation in the script (using `#E` comments)
   - Document any non-obvious behavior

3. **Tests**:
   - Add Bats tests for new functionality
   - Run existing tests to ensure no regressions

## Pull Request Process

1. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**:
   - Add your features or bug fixes
   - Update documentation
   - Add tests for new functionality

3. **Test Your Changes**:
   ```bash
   # Run tests to ensure everything works
   DOKKU_BIN=/usr/local/bin/dokku PLUGIN_DATA_ROOT=/var/lib/dokku/services/gel bats tests/*.bats
   ```

4. **Submit Pull Request**:
   - Provide a clear description of the changes
   - Mention any issues addressed
   - Explain the testing you've performed

## Current Status

The plugin is under active development. The current focus is on:

1. Implementing core EdgeDB service functionality
2. Ensuring compatibility with Dokku's service plugin conventions
3. Improving testing coverage
4. Adding EdgeDB-specific features like schema management

See the README's "Current Testing Status" section for details on which commands are fully implemented and tested.

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (typically MIT for Dokku plugins).

## Questions?

If you have questions about contributing, please open an issue and we'll be happy to help! 