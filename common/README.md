# Common Utilities

This directory contains shared utilities and configuration files used across all installation scripts in this repository.

## Files

### install_utils.sh

A comprehensive bash utility library providing common functions for all installation scripts.

#### Key Functions

##### Conditional Sudo Detection

```bash
needs_sudo(path)
```

Determines if a path requires sudo privileges based on its location:
- **System paths** (`/opt`, `/usr`, `/usr/local`, `/etc`, `/var`, `/local`): Returns `0` (true) - requires sudo
- **User paths** (`$HOME`, `~`, relative paths): Returns `1` (false) - no sudo required

##### Command Execution

```bash
run_cmd(use_sudo, command, args...)
```

Executes commands with or without sudo based on the `use_sudo` flag.

##### Directory Management

```bash
get_install_dir(default_dir)
```

Returns the installation directory from the `INSTALL_DIR` environment variable or uses the default.

```bash
get_profile_file(install_dir, profile_name)
```

Determines the appropriate profile file location:
- System-wide: `/etc/profile.d/${profile_name}.sh`
- User-specific: `$HOME/.profile.d/${profile_name}.sh`

##### Text Insertion

```bash
insert_text(search_string, insert_string, filepath, use_sudo="auto")
```

Safely inserts text into configuration files with automatic sudo detection.

#### Usage

Source the utilities in your scripts:

```bash
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/install_utils.sh"

# Use the functions
if needs_sudo "/opt/myapp"; then
    echo "Installation requires sudo"
fi

run_cmd "true" mkdir -p "/opt/myapp"
```

### mirrors.yaml

Configuration file containing mirror URLs for various package managers optimized for users in China.

#### Supported Mirrors

| Package Manager | Mirror | URL |
|----------------|--------|-----|
| **Python (Pip)** | Tsinghua | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| **Python (Conda)** | PKU | `https://mirrors.pku.edu.cn/anaconda/` |
| **NPM** | NpmMirror | `https://registry.npmmirror.com/` |
| **Docker** | Multiple | Various mirrors (Aliyun, Baidu, Tencent, SJTU, etc.) |
| **Ubuntu APT** | PKU | `https://mirrors.pku.edu.cn/ubuntu/` |

#### Usage

The mirrors configuration can be referenced by installation scripts to configure package managers with optimal mirrors for China.

```bash
# Example: Configure pip mirror
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Example: Configure npm mirror
npm config set registry https://registry.npmmirror.com/
```

## Benefits

1. **DRY Principle**: Eliminates code duplication across installation scripts
2. **Consistency**: Ensures uniform behavior across all installation profiles
3. **Maintainability**: Single source of truth for common functionality
4. **Flexibility**: Easy to update and extend shared utilities
5. **Safety**: Intelligent sudo detection prevents unnecessary privilege escalation

## Integration

All installation directories (`install_scripts_*`) use these shared utilities:

- `install_scripts_nmic_server/` - Production server setup
- `install_scripts_dev-mic_server/` - Development server setup
- `install_scripts_k8s/` - Kubernetes (MicroK8s) setup

Each directory has its own `install_utils.sh` that sources the common utilities:

```bash
#!/usr/bin/env bash
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common"
source "${COMMON_DIR}/install_utils.sh"
```

## Contributing

When adding new utility functions:

1. Add the function to `install_utils.sh` in this directory
2. Document the function with clear comments
3. Update this README with usage examples
4. Test across all installation profiles
