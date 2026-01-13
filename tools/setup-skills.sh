#!/usr/bin/env bash
#
# setup-skills.sh - Set up OpenCode skills and their dependencies
#
# Usage:
#   ./tools/setup-skills.sh [skill-name]
#   ./tools/setup-skills.sh              # Set up all skills
#   ./tools/setup-skills.sh research     # Set up research skill only
#   ./tools/setup-skills.sh document     # Set up document skill only
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OPENCODE_PLUGINS="${HOME}/.opencode/plugins"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"

# Print functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Setup symlinks from .opencode/skill to skills/
setup_symlinks() {
    info "Setting up skill symlinks..."
    
    mkdir -p "${REPO_ROOT}/.opencode/skill"
    
    for skill_dir in "${REPO_ROOT}/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")
            link_path="${REPO_ROOT}/.opencode/skill/${skill_name}"
            target="../../skills/${skill_name}"
            
            if [[ -L "$link_path" ]]; then
                success "Symlink already exists: ${skill_name}"
            elif [[ -e "$link_path" ]]; then
                warn "Path exists but is not a symlink: ${link_path}"
            else
                ln -sf "$target" "$link_path"
                success "Created symlink: ${skill_name} -> ${target}"
            fi
        fi
    done
}

# Setup research skill dependencies
setup_research() {
    info "Setting up research skill..."
    
    # Check for Node.js
    if ! command_exists node; then
        error "Node.js is required but not installed."
        echo "  Install from: https://nodejs.org/"
        return 1
    fi
    success "Node.js found: $(node --version)"
    
    # Check for npm
    if ! command_exists npm; then
        error "npm is required but not installed."
        return 1
    fi
    success "npm found: $(npm --version)"
    
    # Install Playwright
    info "Checking Playwright installation..."
    if ! command_exists playwright; then
        info "Installing Playwright globally..."
        npm install -g playwright
    fi
    success "Playwright available"
    
    # Install Chromium for Playwright
    info "Ensuring Chromium is installed for Playwright..."
    npx playwright install chromium 2>/dev/null || {
        warn "Could not install Chromium automatically."
        echo "  Run manually: npx playwright install chromium"
    }
    
    # Setup Google AI Search plugin
    info "Setting up Google AI Search plugin..."
    mkdir -p "$OPENCODE_PLUGINS"
    
    SEARCH_PLUGIN_DIR="${OPENCODE_PLUGINS}/opencode-google-ai-search"
    if [[ -d "$SEARCH_PLUGIN_DIR" ]]; then
        success "Google AI Search plugin already cloned"
        info "Updating plugin..."
        cd "$SEARCH_PLUGIN_DIR"
        git pull --quiet || warn "Could not update plugin"
    else
        info "Cloning Google AI Search plugin..."
        git clone --quiet https://github.com/IgorWarzocha/Opencode-Google-AI-Search-Plugin.git "$SEARCH_PLUGIN_DIR"
        success "Plugin cloned"
    fi
    
    # Build the plugin
    info "Building Google AI Search plugin..."
    cd "$SEARCH_PLUGIN_DIR"
    npm install --quiet
    npm run build --quiet 2>/dev/null || npm run build
    success "Plugin built"
    
    # Check for Notion token
    if [[ -n "$NOTION_TOKEN" ]]; then
        success "NOTION_TOKEN is set"
    else
        warn "NOTION_TOKEN not set. Notion integration will not work."
        echo "  To enable Notion:"
        echo "  1. Create integration at https://www.notion.so/profile/integrations"
        echo "  2. export NOTION_TOKEN=\"ntn_your_token_here\""
        echo "  3. Share Notion pages with your integration"
    fi
    
    # Verify opencode-mem in config
    info "Checking opencode configuration..."
    if [[ -f "${REPO_ROOT}/.opencode/config.json" ]]; then
        if grep -q "opencode-mem" "${REPO_ROOT}/.opencode/config.json"; then
            success "opencode-mem plugin configured"
        else
            warn "opencode-mem not found in config. Memory features may not work."
        fi
        
        if grep -q "google-ai-search" "${REPO_ROOT}/.opencode/config.json"; then
            success "google-ai-search MCP server configured"
        else
            warn "google-ai-search not found in config."
        fi
    else
        warn "No .opencode/config.json found"
    fi
    
    echo ""
    success "Research skill setup complete!"
    echo ""
    echo "  Usage: /research <topic>"
    echo "  Example: /research MongoDB deployment strategies"
    echo ""
}

# Setup document skill (minimal - no external deps)
setup_document() {
    info "Setting up document skill..."
    
    # Document skill has no external dependencies
    # Just verify the skill file exists
    if [[ -f "${REPO_ROOT}/skills/document/SKILL.md" ]]; then
        success "Document skill found"
    else
        error "Document skill not found at skills/document/SKILL.md"
        return 1
    fi
    
    echo ""
    success "Document skill setup complete!"
    echo ""
    echo "  Usage: /document <description>"
    echo "  Example: /document user guide for carrier integration"
    echo ""
}

# Verify overall setup
verify_setup() {
    info "Verifying setup..."
    echo ""
    
    # Check OpenCode installation
    if command_exists opencode; then
        success "OpenCode installed: $(opencode --version 2>/dev/null || echo 'version unknown')"
    else
        warn "OpenCode not found in PATH"
        echo "  Install from: https://opencode.ai/docs/"
    fi
    
    # Check symlinks
    echo ""
    info "Skill symlinks:"
    for link in "${REPO_ROOT}/.opencode/skill"/*; do
        if [[ -L "$link" ]]; then
            target=$(readlink "$link")
            echo "  $(basename "$link") -> $target"
        fi
    done
    
    # List available skills
    echo ""
    info "Available skills:"
    for skill_dir in "${REPO_ROOT}/skills"/*/; do
        if [[ -f "${skill_dir}SKILL.md" ]]; then
            skill_name=$(basename "$skill_dir")
            description=$(grep -m1 "^description:" "${skill_dir}SKILL.md" | sed 's/description: *//')
            echo "  /$(basename "$skill_name"): ${description:-No description}"
        fi
    done
    echo ""
}

# Main
main() {
    echo ""
    echo "=========================================="
    echo "  OpenCode Skills Setup"
    echo "=========================================="
    echo ""
    
    cd "$REPO_ROOT"
    
    # Always setup symlinks first
    setup_symlinks
    echo ""
    
    case "${1:-all}" in
        research)
            setup_research
            ;;
        document)
            setup_document
            ;;
        all)
            setup_research
            echo ""
            setup_document
            ;;
        verify)
            verify_setup
            ;;
        *)
            error "Unknown skill: $1"
            echo ""
            echo "Available skills:"
            echo "  research  - Web research with source attribution"
            echo "  document  - Product documentation for Viya"
            echo "  all       - Set up all skills (default)"
            echo "  verify    - Verify current setup"
            exit 1
            ;;
    esac
    
    verify_setup
}

main "$@"
