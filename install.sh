#!/bin/bash

# install.sh - Copy dotfiles to $HOME while respecting .installignore

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_action() {
    echo -e "${BLUE}[COPY]${NC} $1"
}

# Check if we're in a directory with dotfiles
if [[ ! -f .installignore ]]; then
    print_warning ".installignore file not found. Creating empty one."
    touch .installignore
fi

print_status "Starting dotfiles installation..."
print_status "Source directory: $(pwd)"
print_status "Target directory: $HOME"

# Read ignore patterns from .installignore (remove empty lines and comments)
ignore_patterns=()
if [[ -f .installignore ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            ignore_patterns+=("$line")
        fi
    done < .installignore
fi

# Add the install script itself and .installignore to ignore patterns
ignore_patterns+=("install.sh" ".installignore" ".git" ".gitignore")

print_status "Ignore patterns: ${ignore_patterns[*]}"

# Function to check if a file should be ignored
should_ignore() {
    local file="$1"
    for pattern in "${ignore_patterns[@]}"; do
        if [[ "$file" == $pattern ]] || [[ "$file" == *"$pattern"* ]]; then
            return 0  # Should ignore
        fi
    done
    return 1  # Should not ignore
}

# Function to copy directory contents recursively
copy_directory() {
    local src_dir="$1"
    local dest_dir="$2"
    
    print_action "Processing directory: $src_dir -> $dest_dir"
    
    # Create destination directory if it doesn't exist
    if ! mkdir -p "$dest_dir"; then
        print_error "Failed to create directory: $dest_dir"
        return 1
    fi
    
    # Copy directory contents recursively using cp
    if cp -r "$src_dir"/* "$dest_dir"/ 2>/dev/null; then
        # Count files that were copied
        local file_count
        file_count=$(find "$src_dir" -type f | wc -l)
        copied_count=$((copied_count + file_count))
        print_status "Copied $file_count files from $src_dir"
    else
        # If cp -r fails, fall back to manual copying
        while IFS= read -r -d '' file; do
            # Get relative path from source directory
            local rel_path="${file#$src_dir/}"
            local dest_file="$dest_dir/$rel_path"
            local dest_file_dir
            dest_file_dir="$(dirname "$dest_file")"
            
            # Create destination directory structure
            if ! mkdir -p "$dest_file_dir"; then
                print_error "Failed to create directory: $dest_file_dir"
                continue
            fi
            
            if [[ -e "$dest_file" ]]; then
                print_warning "Target file already exists: $dest_file"
                read -p "Overwrite? [y/N]: " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    print_status "Skipping $file"
                    continue
                fi
            fi
            
            print_action "Copying: $file -> $dest_file"
            if cp "$file" "$dest_file"; then
                ((copied_count++))
            else
                print_error "Failed to copy: $file -> $dest_file"
                ((failed_count++))
            fi
        done < <(find "$src_dir" -type f -print0 2>/dev/null)
    fi
}

# Counters
copied_count=0
skipped_count=0
failed_count=0

# Enable dotglob to include hidden files
shopt -s dotglob nullglob

# Process all items in current directory
for item in *; do
    # Skip if item doesn't exist (handles case where no files exist)
    if [[ ! -e "$item" ]]; then
        continue
    fi
    
    if should_ignore "$item"; then
        print_warning "Skipping ignored item: $item"
        ((skipped_count++))
        continue
    fi
    
    if [[ -d "$item" ]]; then
        # For directories, copy contents to $HOME/dirname
        target_dir="$HOME/$item"
        
        # Check if target directory exists and ask for confirmation
        if [[ -d "$target_dir" ]]; then
            print_warning "Target directory already exists: $target_dir"
            read -p "Merge contents? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Skipping directory $item"
                ((skipped_count++))
                continue
            fi
        fi
        
        copy_directory "$item" "$target_dir"
        
    elif [[ -f "$item" ]]; then
        # For files, copy directly to $HOME
        target="$HOME/$item"
        
        if [[ -e "$target" ]]; then
            print_warning "Target already exists: $target"
            read -p "Overwrite? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Skipping $item"
                ((skipped_count++))
                continue
            fi
        fi
        
        print_action "Copying file: $item -> $target"
        if cp "$item" "$target"; then
            ((copied_count++))
        else
            print_error "Failed to copy: $item -> $target"
            ((failed_count++))
        fi
    fi
done

# Reset shell options
shopt -u dotglob nullglob

print_status "Installation complete!"
print_status "Files copied: $copied_count"
print_status "Files skipped: $skipped_count"
if [[ $failed_count -gt 0 ]]; then
    print_error "Files failed: $failed_count"
    exit 1
fi

