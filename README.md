# Modular macOS Bootstrap System

A declarative, idempotent, package-driven macOS bootstrap automation built with Ansible and Zsh. It allows you to toggle developer personas/roles on and off without touching the underlying playbook logic.

<span style="color:green">**✓ This playbook is tested via GitHub Actions on macOS runners**</span>


## 🎯 Project Goals

1. **Modular Package Design**: Every tool (Kubernetes, AWS, Python, Developer) is completely self-contained in its own package folder (Brew packages, aliases, functions, static completions, and Antidote plugins).
2. **Lightning-Fast Terminal Startup**: Zero dynamic subshells (`eval`) on terminal load. Uses Zsh lazy-loading (`fpath`), pre-generated static completion files, and pre-compiled Zsh bytecode (`.zwc`).
3. **Live Git Tracking**: Keeps aliases and functions as symlinks back to your local `.dotfiles` repository so local changes can be immediately tracked in Git.
4. **Automated Dependency Resolution**: Recursively resolves package dependencies (e.g., enabling `aws` automatically installs and configures `python`).

---

## 🏗 System Architecture

```text
├── vars.yml                  # Global toggles & requested install_packages
├── playbook.yml              # Core automation engine
├── templates/
│   └── zsh_plugins.txt.j2    # Jinja2 template for Antidote plugins
└── .dotfiles/
    ├── .zshrc                # Optimized Zsh runtime loader
    ├── .config/              # Dotfile symlinks (Starship, Cursor, etc.)
    └── packages/             # Modular package definitions
        ├── core/
        │   ├── package.yml
        │   ├── env.zsh
        │   └── functions/
        ├── kubernetes/
        │   ├── package.yml
        │   ├── env.zsh
        │   ├── functions/
        │   └── completions/  # Static completions (e.g., #compdef k=kubectl)
        ├── aws/
        │   ├── package.yml
        │   ├── env.zsh
        │   └── functions/
        ├── python/
        │   └── package.yml
        ├── developer/
        │   ├── package.yml
        │   ├── env.zsh
        │   └── completions/
        ├── terraform/
        │   ├── package.yml
        │   ├── env.zsh
        │   └── functions/
        ├── argocd/
        │   ├── package.yml
        │   └── functions/
        ├── cursor/
        │   ├── package.yml
        │   ├── env.zsh
        │   └── config links
        ├── antigravity/
        │   ├── package.yml
        │   └── config links
        └── virtualization/
            └── package.yml
```

---

## 📦 Available Packages

### Core Packages
- **core**: Essential tools and base Zsh configuration
- **python**: Python development environment with uv package manager

### Development Tools
- **developer**: General developer tools including Docker, Podman Desktop, and CLI utilities
- **cursor**: Cursor AI editor with configuration file management
- **terraform**: Terraform infrastructure tools with tofuenv and tgswitch for version management

### Cloud & DevOps
- **kubernetes**: Kubernetes toolchain (kubectl, helm, krew, stern) with custom aliases and functions
- **aws**: AWS CLI with extensive helper functions for EC2, CloudFront, ACM operations and role assumption
- **argocd**: ArgoCD GitOps tool with login automation

### Specialized Tools
- **antigravity**: AI-powered graph visualization tool (requires Python package)
- **virtualization**: Virtualization tools for macOS development

---

## 🚀 Quick Start

### Installation
```bash
# Clone and run the bootstrap script
git clone <your-repo-url> macos-bootstrap
cd macos-bootstrap
./install.sh
```

### Configuration
Edit `vars.yml` to enable/disable packages:
```yaml
install_packages: ["core", "python", "developer", "kubernetes", "aws"]
configure_dotfiles: true
configure_system_defaults: false  # Set to true for macOS system preferences
```

### Re-run After Changes
```bash
# Re-run the playbook after modifying vars.yml
ansible-playbook playbook.yml
```

---

## 🔧 Advanced Features

### Dependency Resolution
Packages can declare dependencies using `required_packages` in their `package.yaml`. The system automatically resolves and installs dependencies recursively.

Example from `antigravity/package.yaml`:
```yaml
required_packages:
  - python
```

### Multiple Installation Methods
Each package supports multiple installation methods:
- **brew**: Homebrew formulae and casks
- **curl**: Remote shell scripts
- **shell**: Custom shell commands
- **git**: Clone repositories and install specific files
- **completions**: Dynamic CLI completion generation
- **antidote**: Zsh plugin management
- **config_links**: Configuration file symlinks

### Static Completions
The system pre-generates static completion files for CLI tools to avoid dynamic shell evaluation, ensuring instant terminal startup.

### Zsh Bytecode Compilation
All Zsh configuration files are compiled to `.zwc` bytecode for faster loading and parsing.

---

## 📝 Package Structure

Each package follows a consistent structure:
```
packages/<package-name>/
├── package.yml          # Package definition and dependencies
├── env.zsh             # Environment variables and aliases (optional)
├── functions/          # Custom shell functions (optional)
├── completions/        # Static completion files (optional)
└── config/             # Package-specific config (optional)
```

---

## ⚙️ System Configuration

When `configure_system_defaults: true`, the playbook applies macOS system preferences:
- Disables Spotlight hotkey (Cmd+Space) for use with Raycast
- Sets fast keyboard key-repeat rate
- Configures low initial key-repeat delay

---

## 🎨 Customization

### Adding New Packages
1. Create a new directory under `.dotfiles/packages/<package-name>/`
2. Add a `package.yaml` with package definition
3. Add optional `env.zsh` (for environment variables and aliases), `functions/`, `completions/`, etc.
4. Add the package name to `install_packages` in `vars.yml`

### Modifying Existing Packages
Edit files directly in the `.dotfiles/packages/` directory. Changes are tracked via Git since they're symlinked to your home directory.

---

## 📊 Performance Optimization

The system achieves lightning-fast terminal startup through:
1. **Zero dynamic eval**: No `eval "$(command)"` calls during shell load
2. **Lazy loading**: Zsh functions loaded on-demand via `fpath`
3. **Static completions**: Pre-generated completion files
4. **Bytecode compilation**: `.zwc` files for faster Zsh parsing
5. **Symlink-based**: Git-tracked dotfiles without copying

---

## 🛠 Troubleshooting

### Re-run Bootstrap
```bash
./install.sh
```

### Check Installed Packages
```bash
# View resolved packages
ansible-playbook playbook.yml --tags debug
```

### Manually Recompile Zsh Bytecode
```bash
zsh -c 'autoload -U zrecompile; for f in ~/.config/zsh/env.d/*.zsh(N); do zrecompile -p -R $f; done'
```

### Reset System Defaults
Set `configure_system_defaults: false` in `vars.yml` and re-run the playbook.

---

## 🧪 Testing

### GitHub Actions CI/CD
This playbook includes automated testing via GitHub Actions that runs on macOS runners. The workflow:

- Validates YAML syntax for all configuration files
- Runs Ansible syntax checks
- Tests the playbook with minimal configurations
- Verifies dependency resolution
- Validates package definitions

### Local Testing
You can test the playbook locally without making changes to your system by creating temporary test configuration files:

```bash
# Create a minimal test configuration
cat > vars.test.yaml << 'EOF'
---
install_packages: ["core"]
configure_dotfiles: true
base_config_path: "{{ ansible_env.HOME }}/.config"
zsh_config_path: "{{ base_config_path }}/zsh"
overwrite_config_copy: false
backup_config_copy: true
configure_system_defaults: false
dotfiles_repo: "{{ playbook_dir }}/.dotfiles"
dotfiles_zshrc_src: "{{ dotfiles_repo }}/.zshrc"
system_configurations:
  input_devices:
    keyboard_key_repeat_rate: 2
    keyboard_delay_until_repeat: 15
    trackpad_enable_tap_click_global: true
    trackpad_enable_tap_click_driver: true
    trackpad_enable_three_finger_drag: true
  finder:
    show_hidden_files: true
    show_file_extensions: true
    default_search_scope: "SCcf"
    show_path_bar: true
  spotlight:
    disable_hotkey: true
  desktop:
    hide_all_items: true
  dock:
    auto_hide: true
    position: "left"
EOF

# Test with minimal configuration (dry-run)
ansible-playbook playbook.yaml --extra-vars "@vars.test.yaml" --check

# Clean up test file
rm vars.test.yaml
```

For dependency resolution testing, the GitHub Actions workflow creates test configurations inline to validate that package dependencies (like antigravity → python) are properly resolved.

The workflow also includes a system configuration test that sets `configure_system_defaults: true` to validate the macOS system preference tasks work correctly, including:
- Spotlight hotkey configuration
- Finder settings (hidden files, file extensions, path bar)
- Trackpad and keyboard settings
- Dock and desktop configurations

### Static Validation
Validate YAML syntax without running Ansible:

```bash
python -c "
import yaml
import glob

files = ['playbook.yaml', 'vars.yaml', 'installations.yaml', 'system-configurations.yaml']
files.extend(glob.glob('.dotfiles/packages/*/package.yaml'))

for f in files:
    with open(f) as file:
        yaml.safe_load(file)
    print(f'✓ Valid: {f}')
"
```
