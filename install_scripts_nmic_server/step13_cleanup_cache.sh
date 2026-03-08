#!/bin/bash

CACHE_CLEANER_VERSION="1.0.0"

DEFAULT_DIR_PATTERNS=(
    "__pycache__"
    ".pytest_cache"
    "build"
    "dist"
    "*.egg-info"
    ".eggs"
    ".tox"
    ".nox"
    ".mypy_cache"
    ".ruff_cache"
    "pip-wheel-metadata"
    ".vscode"
    ".idea"
    ".npm"
    ".cache"
    ".nv"
    ".pki"
    ".landscape"
    ".dotnet"
    "logs"
    "_logs"
    "logs_*"
    "*_logs"
)

DEFAULT_FILE_PATTERNS=(
    "*.pyc"
    "*.pyo"
    "*.pyd"
    "*.egg"
    "MANIFEST"
    "MANIFEST.in"
    ".coverage"
    "pip-delete-this-directory.txt"
    "*.swp"
    "*.swo"
    "*.tmp"
    ".DS_Store"
    "Thumbs.db"
    "*.log"
)

DRY_RUN=false
ROOT_PATH=""
USE_CUSTOM_PATTERNS=false
DIR_PATTERNS=()
FILE_PATTERNS=()
FILES_REMOVED=0
DIRS_REMOVED=0
ERRORS=0
TOTAL_SIZE=0
FILES_LIST=""
DIRS_LIST=""

print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] ROOT_FOLDER

Cache Cleaning Script for Folder Trees

This script removes various cache files and directories from a specified root folder.
It cleans Python cache, temporary files, build artifacts, and other common cache patterns.

OPTIONS:
    -h, --help          Show this help message and exit
    -d, --dry-run       Show what would be removed without actually deleting
    -p, --patterns      Comma-separated list of custom cache patterns
    -l, --list-patterns Show available cache patterns and exit
    -v, --version       Show version information and exit

EXAMPLES:
    $(basename "$0") /path/to/project
    $(basename "$0") /path/to/project --dry-run
    $(basename "$0") /path/to/project --patterns "__pycache__,.pytest_cache,*.pyc"
    $(basename "$0") /path/to/project -d -p "*.log,*.tmp"

EOF
}

print_version() {
    echo "Cache Cleaner v${CACHE_CLEANER_VERSION}"
}

list_patterns() {
    echo "Available cache patterns:"
    echo ""
    echo "Directory patterns:"
    for pattern in "${DEFAULT_DIR_PATTERNS[@]}"; do
        echo "  ${pattern} (directory)"
    done
    echo ""
    echo "File patterns:"
    for pattern in "${DEFAULT_FILE_PATTERNS[@]}"; do
        echo "  ${pattern} (file)"
    done
}

calculate_size() {
    local path="$1"
    local size=0
    
    if [[ -f "$path" ]]; then
        size=$(stat -c%s "$path" 2>/dev/null || stat -f%z "$path" 2>/dev/null || echo 0)
    elif [[ -d "$path" ]]; then
        size=$(du -sb "$path" 2>/dev/null | cut -f1 || du -s "$path" 2>/dev/null | cut -f1 || echo 0)
    fi
    
    echo "$size"
}

format_size() {
    local bytes=$1
    local mb=$(echo "scale=2; $bytes / (1024 * 1024)" | bc 2>/dev/null || echo "0")
    echo "${mb}"
}

find_cache_items() {
    local files_tmp=$(mktemp)
    local dirs_tmp=$(mktemp)
    
    echo "🔍 Searching for cache items in: ${ROOT_PATH}"
    
    local dir_patterns=()
    local file_patterns=()
    
    if [[ "$USE_CUSTOM_PATTERNS" == true ]]; then
        dir_patterns=("${DIR_PATTERNS[@]}")
        file_patterns=("${FILE_PATTERNS[@]}")
    else
        dir_patterns=("${DEFAULT_DIR_PATTERNS[@]}")
        file_patterns=("${DEFAULT_FILE_PATTERNS[@]}")
    fi
    
    local dir_args=""
    local first=true
    for pattern in "${dir_patterns[@]}"; do
        if [[ "$first" == true ]]; then
            dir_args="-name ${pattern@Q}"
            first=false
        else
            dir_args="$dir_args -o -name ${pattern@Q}"
        fi
    done
    
    if [[ -n "$dir_args" ]]; then
        eval "find \"$ROOT_PATH\" -type d \\( $dir_args \\) -print0 2>/dev/null" > "$dirs_tmp"
    fi
    
    local file_args=""
    first=true
    for pattern in "${file_patterns[@]}"; do
        if [[ "$first" == true ]]; then
            file_args="-name ${pattern@Q}"
            first=false
        else
            file_args="$file_args -o -name ${pattern@Q}"
        fi
    done
    
    if [[ -n "$file_args" ]]; then
        eval "find \"$ROOT_PATH\" -type f \\( $file_args \\) -print0 2>/dev/null" > "$files_tmp"
    fi
    
    FILES_LIST="$files_tmp"
    DIRS_LIST="$dirs_tmp"
}

count_null_delimited() {
    local file="$1"
    if [[ ! -s "$file" ]]; then
        echo 0
        return
    fi
    tr -cd '\0' < "$file" | wc -c
}

remove_items() {
    local files_count=$(count_null_delimited "$FILES_LIST")
    local dirs_count=$(count_null_delimited "$DIRS_LIST")
    
    if [[ $files_count -gt 0 ]]; then
        echo ""
        echo "🗑️  Removing ${files_count} cache files..."
        
        while IFS= read -r -d '' file_path; do
            if [[ -n "$file_path" ]]; then
                local file_size=$(calculate_size "$file_path")
                
                if [[ "$DRY_RUN" == true ]]; then
                    echo "  [DRY RUN] Would remove file: ${file_path} (${file_size} bytes)"
                else
                    if rm -f "$file_path" 2>/dev/null; then
                        echo "  Removed file: ${file_path} (${file_size} bytes)"
                        ((FILES_REMOVED++))
                        ((TOTAL_SIZE += file_size))
                    else
                        echo "  ❌ Error removing ${file_path}"
                        ((ERRORS++))
                    fi
                fi
            fi
        done < "$FILES_LIST"
    fi
    
    if [[ $dirs_count -gt 0 ]]; then
        echo ""
        echo "🗑️  Removing ${dirs_count} cache directories..."
        
        sort -zr "$DIRS_LIST" | while IFS= read -r -d '' dir_path; do
            if [[ -n "$dir_path" && -d "$dir_path" ]]; then
                local dir_size=$(calculate_size "$dir_path")
                
                if [[ "$DRY_RUN" == true ]]; then
                    echo "  [DRY RUN] Would remove directory: ${dir_path} (${dir_size} bytes)"
                else
                    if rm -rf "$dir_path" 2>/dev/null; then
                        echo "  Removed directory: ${dir_path} (${dir_size} bytes)"
                        ((DIRS_REMOVED++))
                        ((TOTAL_SIZE += dir_size))
                    else
                        echo "  ❌ Error removing ${dir_path}"
                        ((ERRORS++))
                    fi
                fi
            fi
        done
    fi
}

print_summary() {
    local total_items=$((FILES_REMOVED + DIRS_REMOVED))
    local size_mb=$(format_size "$TOTAL_SIZE")
    
    echo ""
    echo "📊 Cleaning Summary:"
    echo "   - Files removed: ${FILES_REMOVED}"
    echo "   - Directories removed: ${DIRS_REMOVED}"
    echo "   - Total items: ${total_items}"
    echo "   - Space freed: ${size_mb} MB"
    echo "   - Errors encountered: ${ERRORS}"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo ""
        echo "⚠️  DRY RUN MODE - No files were actually deleted"
    fi
}

clean_cache() {
    echo "🚀 Starting cache cleaning for: ${ROOT_PATH}"
    
    local dir_patterns=()
    local file_patterns=()
    local all_patterns=()
    
    if [[ "$USE_CUSTOM_PATTERNS" == true ]]; then
        dir_patterns=("${DIR_PATTERNS[@]}")
        file_patterns=("${FILE_PATTERNS[@]}")
        all_patterns=("${DIR_PATTERNS[@]}" "${FILE_PATTERNS[@]}")
        echo "📋 Using patterns: ${all_patterns[*]}"
    else
        dir_patterns=("${DEFAULT_DIR_PATTERNS[@]}")
        file_patterns=("${DEFAULT_FILE_PATTERNS[@]}")
        all_patterns=("${DEFAULT_DIR_PATTERNS[@]}" "${DEFAULT_FILE_PATTERNS[@]}")
        echo "📋 Using patterns: ${all_patterns[*]}"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "🔍 DRY RUN MODE - No files will be deleted"
    fi
    
    find_cache_items
    
    local files_count=$(count_null_delimited "$FILES_LIST")
    local dirs_count=$(count_null_delimited "$DIRS_LIST")
    
    if [[ $files_count -eq 0 && $dirs_count -eq 0 ]]; then
        echo ""
        echo "🎉 No cache files or directories found!"
        rm -f "$FILES_LIST" "$DIRS_LIST"
        return
    fi
    
    echo ""
    echo "📋 Found ${files_count} cache files and ${dirs_count} cache directories"
    
    if [[ $files_count -gt 0 ]]; then
        echo ""
        echo "📄 Files to remove:"
        head -z -n 10 "$FILES_LIST" | while IFS= read -r -d '' file_path; do
            local rel_path="${file_path#$ROOT_PATH/}"
            echo "  - ${rel_path}"
        done
        if [[ $files_count -gt 10 ]]; then
            echo "  ... and $((files_count - 10)) more files"
        fi
    fi
    
    if [[ $dirs_count -gt 0 ]]; then
        echo ""
        echo "📁 Directories to remove:"
        head -z -n 10 "$DIRS_LIST" | while IFS= read -r -d '' dir_path; do
            local rel_path="${dir_path#$ROOT_PATH/}"
            echo "  - ${rel_path}"
        done
        if [[ $dirs_count -gt 10 ]]; then
            echo "  ... and $((dirs_count - 10)) more directories"
        fi
    fi
    
    if [[ "$DRY_RUN" == false && ($files_count -gt 0 || $dirs_count -gt 0) ]]; then
        echo ""
        read -p "⚠️  Are you sure you want to remove these items? (y/N): " response
        if [[ "$response" != "y" && "$response" != "yes" ]]; then
            echo "Operation cancelled."
            rm -f "$FILES_LIST" "$DIRS_LIST"
            return
        fi
    fi
    
    remove_items
    print_summary
    
    rm -f "$FILES_LIST" "$DIRS_LIST"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            -v|--version)
                print_version
                exit 0
                ;;
            -l|--list-patterns)
                list_patterns
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -p|--patterns)
                if [[ -n "$2" ]]; then
                    USE_CUSTOM_PATTERNS=true
                    IFS=',' read -ra custom_patterns <<< "$2"
                    for pattern in "${custom_patterns[@]}"; do
                        pattern=$(echo "$pattern" | xargs)
                        if [[ "$pattern" == *"*"* || "$pattern" == "."* ]]; then
                            FILE_PATTERNS+=("$pattern")
                        else
                            DIR_PATTERNS+=("$pattern")
                        fi
                    done
                    shift 2
                else
                    echo "Error: --patterns requires a value"
                    exit 1
                fi
                ;;
            *)
                if [[ -z "$ROOT_PATH" ]]; then
                    ROOT_PATH="$1"
                else
                    echo "Error: Unknown option: $1"
                    print_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

main() {
    parse_arguments "$@"
    
    if [[ -z "$ROOT_PATH" ]]; then
        echo "Error: Root folder is required"
        print_usage
        exit 1
    fi
    
    if [[ ! -e "$ROOT_PATH" ]]; then
        echo "❌ Error: Root folder '${ROOT_PATH}' does not exist"
        exit 1
    fi
    
    if [[ ! -d "$ROOT_PATH" ]]; then
        echo "❌ Error: '${ROOT_PATH}' is not a directory"
        exit 1
    fi
    
    ROOT_PATH=$(cd "$ROOT_PATH" && pwd)
    
    trap 'echo -e "\n\n⚠️  Operation cancelled by user."; rm -f "$FILES_LIST" "$DIRS_LIST"; exit 1' INT TERM
    
    clean_cache
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
