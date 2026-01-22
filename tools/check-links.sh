#!/bin/bash
#
# check-links.sh - Check for broken internal links in markdown files
#
# This script scans all markdown files in the repository for:
# - Broken relative links to other files (./path/to/file.md)
# - Broken relative links to directories (./path/to/dir/)
#
# Usage:
#   ./tools/check-links.sh           # Check all files
#   ./tools/check-links.sh --fix     # Show suggested fixes
#
# Exit codes:
#   0 - No broken links found
#   1 - Broken links found
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SHOW_FIX=false
if [[ "${1:-}" == "--fix" ]]; then
  SHOW_FIX=true
fi

BROKEN_COUNT=0
CHECKED_COUNT=0
declare -a FILES_WITH_ERRORS

print_header() {
  echo ""
  echo -e "${BLUE}=== $1 ===${NC}"
  echo ""
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

# Find potential matches for a broken link
suggest_fix() {
  local broken_link="$1"
  local basename_link
  basename_link="$(basename "$broken_link")"
  
  # Search for files with similar names
  find "$REPO_ROOT" -name "$basename_link" -type f 2>/dev/null | grep -v ".git" | head -5
  find "$REPO_ROOT" -name "${basename_link%.md}" -type d 2>/dev/null | grep -v ".git" | head -5
}

print_header "Checking Internal Links"

# Find all markdown files
while IFS= read -r -d '' file; do
  relative_file="${file#$REPO_ROOT/}"
  file_has_errors=false
  source_dir="$(dirname "$file")"
  
  # Extract links from file (skip code blocks by removing them first)
  # We use awk to remove fenced code blocks before grep
  links=$(awk '
    /^```/ { in_code = !in_code; next }
    !in_code { print }
  ' "$file" | grep -oP '\[[^\]]*\]\(\K[^)]+' 2>/dev/null | grep -v '^http' | grep -v '^mailto:' | grep -v '^#' || true)
  
  for link in $links; do
    ((CHECKED_COUNT++)) || true
    
    # Remove anchor from link
    link_path="${link%%#*}"
    
    # Skip empty links
    [[ -z "$link_path" ]] && continue
    
    # Skip obvious placeholder/example links
    [[ "$link_path" == "url" ]] && continue
    [[ "$link_path" == "URL" ]] && continue
    [[ "$link_path" == "./file.md" ]] && continue
    [[ "$link_path" == "./other-file.md" ]] && continue
    [[ "$link_path" =~ ^notion:// ]] && continue
    [[ "$link_path" =~ \.\.\.$ ]] && continue  # ends with ...
    [[ "$link_path" =~ XXX ]] && continue  # template placeholders
    [[ "$link_path" =~ ^/docs/ ]] && continue  # external docs references
    [[ "$link_path" =~ related-feature ]] && continue  # example links
    [[ "$link_path" =~ related-page ]] && continue  # example links
    [[ "$link_path" =~ get-resource ]] && continue  # example links
    [[ "$link_path" =~ delete-resource ]] && continue  # example links
    [[ "$link_path" =~ docs-external ]] && continue  # external docs repo
    
    # Decode URL-encoded characters (e.g., %20 -> space)
    link_path=$(echo "$link_path" | sed 's/%20/ /g' | sed 's/%26/\&/g')
    
    # Resolve target path
    if [[ "$link_path" == /* ]]; then
      target_path="$REPO_ROOT${link_path}"
    else
      target_path="$source_dir/$link_path"
    fi
    
    # Check if target exists
    if [[ ! -e "$target_path" ]]; then
      if [[ "$file_has_errors" == false ]]; then
        echo ""
        echo -e "${YELLOW}$relative_file${NC}"
        file_has_errors=true
        FILES_WITH_ERRORS+=("$relative_file")
      fi
      
      print_error "Broken link: $link"
      ((BROKEN_COUNT++)) || true
      
      # Show suggestions if --fix flag
      if [[ "$SHOW_FIX" == true ]]; then
        suggestions=$(suggest_fix "$link")
        if [[ -n "$suggestions" ]]; then
          echo "    Possible matches:"
          echo "$suggestions" | while read -r match; do
            [[ -n "$match" ]] && echo "      - ${match#$REPO_ROOT/}"
          done
        fi
      fi
    fi
  done
done < <(find "$REPO_ROOT" -name "*.md" -type f ! -path "*/.git/*" ! -path "*/node_modules/*" -print0)

# Summary
print_header "Summary"

FILE_COUNT=$(find "$REPO_ROOT" -name "*.md" -type f ! -path "*/.git/*" | wc -l | tr -d ' ')
echo "Files scanned: $FILE_COUNT"
echo "Links checked: $CHECKED_COUNT"

if [[ $BROKEN_COUNT -eq 0 ]]; then
  print_success "No broken links found!"
  exit 0
else
  print_error "Found $BROKEN_COUNT broken link(s) in ${#FILES_WITH_ERRORS[@]} file(s)"
  echo ""
  echo "Files with broken links:"
  for f in "${FILES_WITH_ERRORS[@]}"; do
    echo "  - $f"
  done
  echo ""
  if [[ "$SHOW_FIX" == false ]]; then
    echo "Run with --fix to see suggested fixes:"
    echo "  ./tools/check-links.sh --fix"
  fi
  exit 1
fi
