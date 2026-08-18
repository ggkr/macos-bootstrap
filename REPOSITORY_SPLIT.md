# Repository Split Documentation

## Overview

This repository has been split into two separate repositories to better separate concerns and improve maintainability:

1. **Dotfiles Repository**: Contains configuration files, shell scripts, and environment setup
2. **Packages Repository**: Contains package definitions, playbooks, and orchestration logic

## Repository Structure

### Original Structure (Single Repository)
```
macos-bootstrap/
├── .dotfiles/
│   ├── .config/          # Configuration files
│   └── packages/         # Package definitions
├── playbook.yaml
├── vars.yaml
└── tasks/
```

### New Structure (Split Repositories)

#### Dotfiles Repository
```
dotfiles/
├── .config/
│   ├── git/
│   ├── vim/
│   ├── starship/
│   ├── zsh/
│   └── ... (other app configs)
└── README.md
```

#### Packages Repository (Current Repository)
```
macos-bootstrap/
├── packages/             # Package definitions (moved from .dotfiles)
│   ├── core/
│   ├── developer/
│   ├── kubernetes/
│   └── ...
├── playbook.yaml
├── vars.yaml
└── tasks/
    ├── git-setup.yaml    # NEW: Git and Homebrew setup
    ├── installations.yaml
    └── system-configurations.yaml
```

## Configuration

### 1. Dotfiles Repository Configuration

Edit `vars.yaml` to configure your dotfiles repository:

```yaml
# Git Configuration (Optional)
git_user_name: "Your Name"
git_user_email: "your.email@example.com"
git_setup_ssh: true  # Generate SSH keys for git
git_ssh_key_type: "ed25519"
git_use_ssh: true   # Use SSH for cloning (false for HTTPS)

# Repository Configuration
dotfiles_repo: "{{ ansible_env.HOME }}/dotfiles"
dotfiles_repo_url: "git@github.com:yourusername/dotfiles.git"
# dotfiles_repo_url_https: "https://github.com/yourusername/dotfiles.git"
```

### 2. Packages Repository Configuration

If you want to keep packages in a separate repository:

```yaml
packages_repo: "{{ ansible_env.HOME }}/macos-packages"
packages_repo_url: "git@github.com:yourusername/macos-packages.git"
# packages_repo_url_https: "https://github.com/yourusername/macos-packages.git"
```

### 3. Local Development (Fallback)

For local development without remote repositories, the playbook will use the local `.dotfiles` directory:

```yaml
dotfiles_repo_fallback: "{{ playbook_dir }}/.dotfiles"
```

## Migration Guide

### Step 1: Create the Dotfiles Repository

1. Create a new repository for your dotfiles
2. Move the following content from the current repository:
   - `.dotfiles/.config/` → Repository root `.config/`
   - Keep `.dotfiles/packages/` in the current repository

3. Initialize the new repository:
```bash
cd ~/dotfiles
git init
git add .
git commit -m "Initial dotfiles commit"
git remote add origin git@github.com:yourusername/dotfiles.git
git push -u origin main
```

### Step 2: Update Package Definitions

Update package definitions to reference the new dotfiles structure. The paths in `config_links` and `config_copy` should remain relative to the dotfiles repository root.

Example from `packages/core/package.yaml`:
```yaml
config_links:
  .config/.zshrc: ~/.zshrc
  .config/vim/.vimrc: ~/.vimrc
  .config/starship/starship.toml: ~/.config/starship.toml
```

### Step 3: Configure the Playbook

Update `vars.yaml` with your repository URLs and git configuration.

### Step 4: Test the Setup

Run the playbook to test the new structure:
```bash
ansible-playbook playbook.yaml
```

## Features

### Git Setup (`tasks/git-setup.yaml`)

The new `git-setup.yaml` task file handles:

1. **Homebrew Installation**: Automatically installs Homebrew if not present
2. **Git Installation**: Installs Git via Homebrew
3. **Git Configuration**: Optionally configures user name and email
4. **SSH Key Setup**: Optionally generates SSH keys for Git operations
5. **Repository Cloning**: Clones dotfiles and packages repositories

### Flexible Repository Configuration

The playbook supports multiple scenarios:

1. **Remote repositories**: Uses configured Git URLs
2. **Local development**: Falls back to local `.dotfiles` directory
3. **SSH/HTTPS**: Supports both SSH and HTTPS Git protocols
4. **Combined or split**: Can use single repository or split structure

### Backward Compatibility

The playbook maintains backward compatibility:

- If repository URLs are not configured, it uses the local `.dotfiles` directory
- Existing package definitions continue to work without modification
- The split is optional - you can continue using a single repository

## Usage Examples

### Basic Setup (Remote Repositories)

```yaml
# vars.yaml
git_user_name: "John Doe"
git_user_email: "john@example.com"
git_setup_ssh: true
dotfiles_repo_url: "git@github.com:john/dotfiles.git"
```

### Local Development

```yaml
# vars.yaml
# No repository URLs configured - uses local .dotfiles
dotfiles_repo_fallback: "{{ playbook_dir }}/.dotfiles"
```

### HTTPS Instead of SSH

```yaml
# vars.yaml
git_use_ssh: false
dotfiles_repo_url: "git@github.com:john/dotfiles.git"
dotfiles_repo_url_https: "https://github.com/john/dotfiles.git"
```

### Separate Packages Repository

```yaml
# vars.yaml
dotfiles_repo_url: "git@github.com:john/dotfiles.git"
packages_repo: "{{ ansible_env.HOME }}/macos-packages"
packages_repo_url: "git@github.com:john/macos-packages.git"
```

## Benefits of the Split

1. **Separation of Concerns**: Configuration files are separated from package management logic
2. **Independent Updates**: Update dotfiles without affecting package definitions
3. **Reusability**: Use the same dotfiles across different projects or machines
4. **Smaller Repository Size**: Each repository is more focused and smaller
5. **Better Organization**: Clear separation between what to install and how to configure it
6. **Flexibility**: Mix and match different dotfiles with different package sets

## Troubleshooting

### Repository Cloning Issues

If you encounter issues cloning repositories:

1. Check your Git configuration: `git config --list`
2. Verify SSH keys are added to your Git hosting service
3. Test repository access manually: `git clone git@github.com:yourusername/dotfiles.git`
4. Try HTTPS instead of SSH by setting `git_use_ssh: false`

### Path Issues

If paths are not resolving correctly:

1. Check the repository paths in `vars.yaml`
2. Verify the fallback path points to the correct location
3. Check that the playbook directory (`playbook_dir`) is correct

### Backward Compatibility

If you want to continue using the old single-repository structure:

1. Keep everything in the `.dotfiles` directory
2. Don't configure repository URLs in `vars.yaml`
3. The playbook will automatically use the local fallback

## Future Enhancements

Potential future improvements:

1. **Multiple Environment Support**: Different dotfiles for work/personal
2. **Dotfiles Switching**: Easy switching between different dotfiles configurations
3. **Package Repository Registry**: Support for multiple package repositories
4. **Automated Testing**: Test playbook changes without affecting system
5. **Rollback Support**: Ability to rollback configuration changes

## Support

For issues or questions:

1. Check this documentation first
2. Review the ansible playbook task files for detailed implementation
3. Check the individual package definitions for package-specific issues
4. Verify your Git and SSH configuration if repository cloning fails
