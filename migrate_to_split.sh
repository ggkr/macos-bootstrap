#!/bin/bash
# Migration script to split macos-bootstrap into separate dotfiles and packages repositories

set -e

echo "=========================================="
echo "macOS Bootstrap Repository Split Script"
echo "=========================================="
echo ""

# Configuration
ORIGINAL_REPO="$(pwd)"
DOTFILES_REPO="${HOME}/dotfiles"
PACKAGES_REPO="${ORIGINAL_REPO}"  # Keep packages in current repo

# Check if we're in the right directory
if [ ! -f "playbook.yaml" ]; then
    echo "Error: playbook.yaml not found. Please run this script from the macos-bootstrap repository root."
    exit 1
fi

echo "Current repository: ${ORIGINAL_REPO}"
echo "Target dotfiles repository: ${DOTFILES_REPO}"
echo "Packages repository: ${PACKAGES_REPO}"
echo ""

# Confirm migration
read -p "Do you want to proceed with the migration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 0
fi

echo ""
echo "Step 1: Creating dotfiles repository..."
if [ -d "${DOTFILES_REPO}" ]; then
    echo "Dotfiles directory already exists: ${DOTFILES_REPO}"
    read -p "Do you want to use existing directory? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 0
    fi
else
    mkdir -p "${DOTFILES_REPO}"
    cd "${DOTFILES_REPO}"
    git init
    echo "Initialized git repository in ${DOTFILES_REPO}"
fi

echo ""
echo "Step 2: Moving configuration files to dotfiles repository..."
cd "${ORIGINAL_REPO}"

# Check if .dotfiles exists
if [ -d ".dotfiles" ]; then
    # Move .config to dotfiles repo
    if [ -d ".dotfiles/.config" ]; then
        echo "Moving .config to dotfiles repository..."
        cp -r .dotfiles/.config "${DOTFILES_REPO}/"
        echo "✓ Moved .config"
    else
        echo "Warning: .dotfiles/.config not found"
    fi
    
    # Check if there are any other files in .dotfiles that should go to dotfiles repo
    echo "Checking for other dotfiles..."
    for item in .dotfiles/*; do
        if [ -d "$item" ] && [ "$(basename "$item")" != "packages" ]; then
            echo "Moving $(basename "$item") to dotfiles repository..."
            cp -r "$item" "${DOTFILES_REPO}/"
            echo "✓ Moved $(basename "$item")"
        fi
    done
else
    echo "Warning: .dotfiles directory not found in original repository"
fi

echo ""
echo "Step 3: Setting up packages repository..."
# Packages stay in the current repository
if [ -d ".dotfiles/packages" ]; then
    echo "Moving packages to repository root..."
    mv .dotfiles/packages ./packages
    echo "✓ Moved packages to repository root"
else
    echo "Warning: .dotfiles/packages not found"
fi

# Remove empty .dotfiles directory if it exists
if [ -d ".dotfiles" ] && [ -z "$(ls -A .dotfiles)" ]; then
    rmdir .dotfiles
    echo "✓ Removed empty .dotfiles directory"
fi

echo ""
echo "Step 4: Committing changes to dotfiles repository..."
cd "${DOTFILES_REPO}"
git add .
git commit -m "Initial dotfiles commit from macos-bootstrap split"
echo "✓ Committed dotfiles"

echo ""
echo "Step 5: Updating vars.yaml configuration..."
cd "${ORIGINAL_REPO}"

# Check if vars.yaml exists
if [ -f "vars.yaml" ]; then
    # Backup original vars.yaml
    cp vars.yaml vars.yaml.backup
    echo "✓ Backed up original vars.yaml to vars.yaml.backup"
    
    # The vars.yaml has already been updated with the new structure
    echo "✓ vars.yaml already contains new repository configuration"
    echo "  Please update the following variables in vars.yaml:"
    echo "  - dotfiles_repo_url: Set to your dotfiles repository URL"
    echo "  - git_user_name: Set your git user name (optional)"
    echo "  - git_user_email: Set your git user email (optional)"
else
    echo "Warning: vars.yaml not found"
fi

echo ""
echo "Step 6: Committing changes to packages repository..."
git add -A
git commit -m "Split repository: moved packages to root, updated for split structure"
echo "✓ Committed packages repository changes"

echo ""
echo "=========================================="
echo "Migration completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Add remote to your dotfiles repository:"
echo "   cd ${DOTFILES_REPO}"
echo "   git remote add origin <your-dotfiles-repo-url>"
echo "   git push -u origin main"
echo ""
echo "2. Update vars.yaml with your repository URLs"
echo ""
echo "3. Test the new setup:"
echo "   cd ${ORIGINAL_REPO}"
echo "   ansible-playbook playbook.yaml"
echo ""
echo "4. (Optional) Remove the old .dotfiles directory if it still exists"
echo ""
echo "For more information, see REPOSITORY_SPLIT.md"
