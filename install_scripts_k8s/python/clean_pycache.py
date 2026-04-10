#!/usr/bin/env python3
"""
Cache Cleaner Script

This script removes various types of cache files and directories from a specified code path.
Supports Python cache files, node_modules, build directories, and other common cache patterns.

Usage:
    python clean_pycache.py [path] [options]
    
Examples:
    python clean_pycache.py                    # Clean current directory
    python clean_pycache.py /path/to/project   # Clean specific path
    python clean_pycache.py --dry-run          # Show what would be deleted
    python clean_pycache.py --verbose          # Show detailed output
"""

import os
import shutil
import argparse
import sys
from pathlib import Path
from typing import List, Set


class CacheCleaner:
    """A utility class to clean various types of cache files and directories."""
    
    def __init__(self, verbose: bool = False, dry_run: bool = False):
        self.verbose = verbose
        self.dry_run = dry_run
        self.deleted_count = 0
        self.deleted_size = 0
        
        # Define cache patterns to clean
        self.cache_dirs = {
            '__pycache__',
            '.pytest_cache',
            '.mypy_cache',
            '.tox',
            'node_modules',
            '.next',
            '.nuxt',
            'dist',
            'build',
            '.cache',
            '.parcel-cache',
            '.vscode',
            '.idea',
            'target',  # Rust/Java
            'bin',     # Some build systems
            'obj',     # C#/.NET
        }
        
        self.cache_files = {
            '*.pyc',
            '*.pyo',
            '*.pyd',
            '.DS_Store',
            'Thumbs.db',
            '*.log',
            '*.tmp',
            '*.temp',
            '.coverage',
            'coverage.xml',
            '*.egg-info',
        }
        
        self.cache_extensions = {
            '.pyc', '.pyo', '.pyd', '.log', '.tmp', '.temp'
        }
    
    def get_directory_size(self, path: Path) -> int:
        """Calculate the total size of a directory."""
        total_size = 0
        try:
            for dirpath, dirnames, filenames in os.walk(path):
                for filename in filenames:
                    filepath = os.path.join(dirpath, filename)
                    try:
                        total_size += os.path.getsize(filepath)
                    except (OSError, FileNotFoundError):
                        pass
        except (OSError, PermissionError):
            pass
        return total_size
    
    def get_file_size(self, path: Path) -> int:
        """Get the size of a file."""
        try:
            return path.stat().st_size
        except (OSError, FileNotFoundError):
            return 0
    
    def format_size(self, size_bytes: int) -> str:
        """Format file size in human readable format."""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} TB"
    
    def should_clean_directory(self, dir_path: Path) -> bool:
        """Check if a directory should be cleaned."""
        return dir_path.name in self.cache_dirs
    
    def should_clean_file(self, file_path: Path) -> bool:
        """Check if a file should be cleaned."""
        # Check by extension
        if file_path.suffix in self.cache_extensions:
            return True
        
        # Check by exact name
        if file_path.name in {'.DS_Store', 'Thumbs.db', '.coverage', 'coverage.xml'}:
            return True
        
        # Check patterns
        if file_path.name.endswith('.egg-info'):
            return True
            
        return False
    
    def clean_directory(self, dir_path: Path) -> None:
        """Remove a cache directory."""
        if not dir_path.exists():
            return
            
        size = self.get_directory_size(dir_path)
        
        if self.dry_run:
            print(f"[DRY RUN] Would delete directory: {dir_path} ({self.format_size(size)})")
        else:
            try:
                shutil.rmtree(dir_path)
                self.deleted_count += 1
                self.deleted_size += size
                if self.verbose:
                    print(f"Deleted directory: {dir_path} ({self.format_size(size)})")
            except (OSError, PermissionError) as e:
                print(f"Error deleting directory {dir_path}: {e}")
    
    def clean_file(self, file_path: Path) -> None:
        """Remove a cache file."""
        if not file_path.exists():
            return
            
        size = self.get_file_size(file_path)
        
        if self.dry_run:
            print(f"[DRY RUN] Would delete file: {file_path} ({self.format_size(size)})")
        else:
            try:
                file_path.unlink()
                self.deleted_count += 1
                self.deleted_size += size
                if self.verbose:
                    print(f"Deleted file: {file_path} ({self.format_size(size)})")
            except (OSError, PermissionError) as e:
                print(f"Error deleting file {file_path}: {e}")
    
    def clean_path(self, root_path: Path) -> None:
        """Clean cache files and directories from the given path."""
        if not root_path.exists():
            print(f"Error: Path {root_path} does not exist")
            return
        
        if not root_path.is_dir():
            print(f"Error: Path {root_path} is not a directory")
            return
        
        print(f"Cleaning cache from: {root_path.absolute()}")
        
        # Walk through all directories and files
        for root, dirs, files in os.walk(root_path):
            root_path_obj = Path(root)
            
            # Check directories (make a copy of dirs list to avoid modification during iteration)
            dirs_to_remove = []
            for dir_name in dirs[:]:
                dir_path = root_path_obj / dir_name
                if self.should_clean_directory(dir_path):
                    self.clean_directory(dir_path)
                    dirs_to_remove.append(dir_name)
            
            # Remove cleaned directories from dirs list to avoid walking into them
            for dir_name in dirs_to_remove:
                dirs.remove(dir_name)
            
            # Check files
            for file_name in files:
                file_path = root_path_obj / file_name
                if self.should_clean_file(file_path):
                    self.clean_file(file_path)
    
    def print_summary(self) -> None:
        """Print cleaning summary."""
        if self.dry_run:
            print(f"\n[DRY RUN] Summary: Would delete {self.deleted_count} items")
        else:
            print(f"\nSummary: Deleted {self.deleted_count} items, freed {self.format_size(self.deleted_size)}")


def main():
    """Main function to handle command line arguments and execute cleaning."""
    parser = argparse.ArgumentParser(
        description="Clean cache files and directories from a code path",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                        # Clean current directory
  %(prog)s /path/to/project       # Clean specific path
  %(prog)s --dry-run              # Show what would be deleted
  %(prog)s --verbose              # Show detailed output
  %(prog)s /path --dry-run -v     # Combine options

Cache types cleaned:
  - Python: __pycache__, *.pyc, *.pyo, *.pyd, .pytest_cache, .mypy_cache
  - Node.js: node_modules, .next, .nuxt
  - Build: dist, build, target, bin, obj
  - IDE: .vscode, .idea
  - System: .DS_Store, Thumbs.db
  - Other: .cache, .parcel-cache, *.log, *.tmp
"""
    )
    
    parser.add_argument(
        'path',
        nargs='?',
        default='.',
        help='Path to clean (default: current directory)'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Show detailed output'
    )
    
    parser.add_argument(
        '-n', '--dry-run',
        action='store_true',
        help='Show what would be deleted without actually deleting'
    )
    
    parser.add_argument(
        '--version',
        action='version',
        version='Cache Cleaner 1.0.0'
    )
    
    args = parser.parse_args()
    
    # Create cleaner instance
    cleaner = CacheCleaner(verbose=args.verbose, dry_run=args.dry_run)
    
    # Convert path to Path object
    target_path = Path(args.path).resolve()
    
    try:
        # Clean the path
        cleaner.clean_path(target_path)
        
        # Print summary
        cleaner.print_summary()
        
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()