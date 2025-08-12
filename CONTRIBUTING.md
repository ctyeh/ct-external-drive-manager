# Contributing to CTExternalDisk Auto-Mount System

Thank you for your interest in contributing to the CTExternalDisk Auto-Mount System! This document provides guidelines for contributing to the project.

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow:

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment for all contributors
- Report any unacceptable behavior to the project maintainers

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue templates** when available
3. **Provide detailed information** including:
   - macOS version
   - System configuration
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant log files

### Suggesting Features

We welcome feature suggestions! Please:

1. **Check existing feature requests** first
2. **Describe the use case** clearly
3. **Explain the expected behavior**
4. **Consider implementation complexity**

### Contributing Code

#### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/ctexternaldisk-automount.git
   cd ctexternaldisk-automount
   ```

2. **Create a development branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install development dependencies**
   ```bash
   ./dev/setup.sh  # If available
   ```

#### Coding Standards

##### Shell Scripting Guidelines

1. **Use bash shebang**: `#!/bin/bash`
2. **Enable strict mode**: `set -euo pipefail` when appropriate
3. **Use meaningful variable names**: `device_name` not `dn`
4. **Quote variables**: `"$variable"` not `$variable`
5. **Check command success**: Use `if command; then` or `command || handle_error`

##### Code Style

```bash
# Good
function mount_device() {
    local device_name="$1"
    local mount_point="/Volumes/$device_name"
    
    if diskutil mount "$device_name"; then
        log_message "✅ Device mounted successfully"
        return 0
    else
        log_message "❌ Failed to mount device"
        return 1
    fi
}

# Avoid
mount_device() {
device_name=$1
mount_point=/Volumes/$device_name
diskutil mount $device_name
}
```

##### Error Handling

Always include proper error handling:

```bash
# Good
if ! command_that_might_fail; then
    log_error "Command failed: $?"
    return 1
fi

# Better
command_that_might_fail || {
    log_error "Command failed with exit code: $?"
    cleanup_on_error
    return 1
}
```

##### Logging

Use consistent logging throughout:

```bash
# Use the existing logging functions
log_message "Info message"
log_error "Error message"
log_debug "Debug message"  # Only when debug mode enabled

# Include timestamps and context
log_message "$(date): Starting mount operation for $device_name"
```

#### Testing

##### Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test categories
./tests/test_mount.sh
./tests/test_hibernation.sh
./tests/test_ownership.sh
```

##### Writing Tests

When adding new features, include tests:

```bash
# tests/test_your_feature.sh
#!/bin/bash

test_your_feature() {
    # Setup
    local test_device="TestDevice"
    
    # Execute
    result=$(your_function "$test_device")
    
    # Verify
    if [[ "$result" == "expected_output" ]]; then
        echo "✅ Test passed: your_feature"
        return 0
    else
        echo "❌ Test failed: your_feature"
        echo "Expected: expected_output"
        echo "Got: $result"
        return 1
    fi
}

# Run test
test_your_feature
```

#### Documentation

##### Code Documentation

- **Comment complex logic**: Explain why, not what
- **Document functions**: Include purpose, parameters, return values
- **Update API documentation**: Keep `docs/API.md` current

```bash
# Mount device using hibernation-safe methods
# Parameters:
#   $1: device_node (e.g., "disk7s1")
# Returns:
#   0: Success
#   1: Mount failed
mount_disk_hibernation_safe() {
    local device_node="$1"
    
    # Try multiple mount methods for reliability
    # Method 1: Standard diskutil (usually works)
    if diskutil mount "$device_node" >/dev/null 2>&1; then
        return 0
    fi
    
    # Method 2: Elevated diskutil (for permission issues)
    # ... rest of function
}
```

##### User Documentation

- **Update relevant guides**: Installation, User Guide, Troubleshooting
- **Include examples**: Show real usage scenarios
- **Keep it current**: Update version numbers and features

#### Pull Request Process

1. **Create a focused PR**: One feature or fix per PR
2. **Write a clear title**: Describe what the PR does
3. **Include a description**: Explain the changes and why
4. **Reference issues**: Use "Fixes #123" or "Addresses #456"
5. **Update documentation**: Include relevant doc updates
6. **Add tests**: Ensure new code is tested

##### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] Tested on macOS version: X.X
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Documentation
- [ ] Updated relevant documentation
- [ ] Added code comments where needed
- [ ] Updated API documentation if applicable

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] No unnecessary debug code left
- [ ] Commit messages are clear and descriptive
```

### Development Workflow

#### Branch Naming

- **Features**: `feature/description-of-feature`
- **Bug fixes**: `fix/description-of-fix`
- **Documentation**: `docs/description-of-update`
- **Refactoring**: `refactor/description-of-refactor`

#### Commit Messages

Use clear, descriptive commit messages:

```bash
# Good
git commit -m "Add hibernation recovery detection to mount script"
git commit -m "Fix ownership repair for APFS volumes"
git commit -m "Update installation guide with troubleshooting steps"

# Avoid
git commit -m "Fix bug"
git commit -m "Update stuff"
git commit -m "WIP"
```

#### Code Review

All contributions go through code review:

1. **Be responsive**: Address feedback promptly
2. **Be open to suggestions**: Consider alternative approaches
3. **Explain your reasoning**: Help reviewers understand your choices
4. **Test suggested changes**: Verify that feedback is addressed

### Project Structure

Understanding the project structure helps with contributions:

```
ctexternaldisk-automount/
├── bin/                    # Executable scripts
├── config/                 # Configuration files
├── docs/                   # Documentation
├── tests/                  # Test scripts
├── examples/               # Usage examples
├── dev/                    # Development tools
├── install.sh              # Main installer
├── README.md               # Project overview
├── LICENSE                 # MIT license
└── CONTRIBUTING.md         # This file
```

### Areas for Contribution

We welcome contributions in these areas:

#### High Priority
- **Bug fixes**: Especially hibernation-related issues
- **Performance improvements**: Faster mounting, lower resource usage
- **Compatibility**: Support for different macOS versions
- **Testing**: More comprehensive test coverage

#### Medium Priority
- **Documentation**: Improve existing docs, add examples
- **Error handling**: Better error messages and recovery
- **Logging**: Enhanced logging and debugging features
- **Configuration**: More customization options

#### Future Features
- **GUI application**: Native macOS app interface
- **Multiple drives**: Support for multiple external drives
- **Notifications**: System notification integration
- **Monitoring**: Performance and health monitoring

### Getting Help

If you need help with development:

1. **Check the documentation**: Start with existing docs
2. **Search issues**: Look for similar questions
3. **Ask in discussions**: Use GitHub Discussions for questions
4. **Contact maintainers**: For complex architectural questions

### Recognition

Contributors are recognized in:

- **README.md**: Major contributors listed
- **Release notes**: Contributions acknowledged
- **Git history**: All commits preserved with attribution

### Development Environment

#### Recommended Tools

- **Shell**: bash 4.0+ or zsh
- **Editor**: VS Code with ShellCheck extension
- **Testing**: Manual testing on real macOS systems
- **Debugging**: Console.app for system logs

#### Useful Commands

```bash
# Check shell syntax
shellcheck bin/ctdisk

# Test installation
./install.sh

# Monitor logs in real-time
tail -f ~/.local/log/ctexternaldisk-mount.log

# Check service status
launchctl list | grep ctexternaldisk
```

Thank you for contributing to the CTExternalDisk Auto-Mount System! Your contributions help make external drive management seamless for the macOS community.
