import subprocess
import pandas as pd
from tabulate import tabulate
import sys
import os
import importlib.metadata

def get_installed_packages():
    """Get a list of installed packages and their versions using pip."""
    try:
        # Run pip list command and capture output
        result = subprocess.run([sys.executable, '-m', 'pip', 'list'], 
                               capture_output=True, text=True, check=True)
        
        # Parse the output
        lines = result.stdout.strip().split('\n')[2:]  # Skip header lines
        packages = []
        
        for line in lines:
            parts = line.split()
            if len(parts) >= 2:
                package_name = parts[0]
                version = parts[1]
                packages.append({"Package": package_name, "Version": version})
        
        return packages
    except subprocess.CalledProcessError as e:
        print(f"Error running pip list: {e}")
        return []

def get_package_dependencies():
    """Get dependencies for each installed package using importlib.metadata."""
    dependencies = {}
    
    # Get all installed distributions
    try:
        distributions = list(importlib.metadata.distributions())
        
        for dist in distributions:
            package_name = dist.metadata['Name']
            deps = []
            
            # Get dependencies from requires attribute
            try:
                requires = dist.requires or []
                for req in requires:
                    # Extract the package name from the requirement string
                    dep_name = req.split(';')[0].split('[')[0].split('(')[0].strip()
                    deps.append(dep_name)
            except Exception:
                pass
            
            dependencies[package_name] = deps
    except Exception as e:
        print(f"Error getting dependencies: {e}")
    
    return dependencies

def check_dependency_issues(packages, dependencies):
    """Check for dependency issues in installed packages using importlib.metadata."""
    # Create a set of all installed package names (case-insensitive)
    installed_packages = {pkg["Package"].lower(): pkg["Version"] for pkg in packages}
    
    # Dictionary to store package distribution objects
    dist_dict = {}
    for dist in importlib.metadata.distributions():
        dist_dict[dist.metadata['Name'].lower()] = dist
    
    # Check each package's dependencies
    issues = {}
    for package in packages:
        package_name = package["Package"]
        package_issues = []
        
        # Find the package in dependencies
        for dep_name in dependencies:
            if dep_name.lower() == package_name.lower():
                # Check if all dependencies are installed
                for dependency in dependencies[dep_name]:
                    if dependency.lower() not in installed_packages:
                        package_issues.append(f"Missing dependency: {dependency}")
                break
        
        # Check for version compatibility issues
        try:
            dist = dist_dict.get(package_name.lower())
            if dist and dist.requires:
                for req_str in dist.requires:
                    # Parse requirement string to get name and version constraint
                    parts = req_str.split(';')[0].split('[')[0]
                    if '(' in parts:
                        req_name = parts.split('(')[0].strip().lower()
                        version_constraint = parts.split('(')[1].rstrip(')')
                        
                        if req_name not in installed_packages:
                            package_issues.append(f"Missing dependency: {req_name}")
                        else:
                            # Here we could add version checking logic if needed
                            pass
                    else:
                        req_name = parts.strip().lower()
                        if req_name not in installed_packages:
                            package_issues.append(f"Missing dependency: {req_name}")
        except Exception as e:
            package_issues.append(f"Error checking dependencies: {str(e)}")
        
        if package_issues:
            issues[package_name] = package_issues
    
    return issues

def generate_summary_table(packages, output_format='markdown'):
    """Generate a summary table of packages in the specified format."""
    if not packages:
        return "No packages found."
    
    # Get dependencies for all packages
    dependencies = get_package_dependencies()
    
    # Check for dependency issues
    dependency_issues = check_dependency_issues(packages, dependencies)
    
    # Add dependencies and issues to the package info
    for package in packages:
        package_name = package["Package"]
        
        # Add dependencies
        for dep_name in dependencies:
            if dep_name.lower() == package_name.lower():
                package["Dependencies"] = ", ".join(dependencies[dep_name]) if dependencies[dep_name] else "None"
                break
        else:
            package["Dependencies"] = "Unknown"
        
        # Add dependency issues
        if package_name in dependency_issues:
            package["Dependency Issues"] = "; ".join(dependency_issues[package_name])
        else:
            package["Dependency Issues"] = "None"
    
    df = pd.DataFrame(packages)
    
    if output_format == 'markdown':
        return tabulate(df, headers='keys', tablefmt='pipe', showindex=False)
    elif output_format == 'html':
        return df.to_html(index=False)
    elif output_format == 'csv':
        return df.to_csv(index=False)
    else:
        return tabulate(df, headers='keys', tablefmt='simple', showindex=False)

def save_to_file(packages, file_path):
    """Save package information to a file based on file extension."""
    # Get dependencies for all packages
    dependencies = get_package_dependencies()
    
    # Check for dependency issues
    dependency_issues = check_dependency_issues(packages, dependencies)
    
    # Add dependencies and issues to the package info
    for package in packages:
        package_name = package["Package"]
        
        # Add dependencies
        for dep_name in dependencies:
            if dep_name.lower() == package_name.lower():
                package["Dependencies"] = ", ".join(dependencies[dep_name]) if dependencies[dep_name] else "None"
                break
        else:
            package["Dependencies"] = "Unknown"
        
        # Add dependency issues
        if package_name in dependency_issues:
            package["Dependency Issues"] = "; ".join(dependency_issues[package_name])
        else:
            package["Dependency Issues"] = "None"
    
    df = pd.DataFrame(packages)
    
    # Determine file type from extension
    _, ext = os.path.splitext(file_path)
    ext = ext.lower()
    
    if ext == '.csv':
        df.to_csv(file_path, index=False)
        return f"Package summary saved to CSV file: {file_path}"
    elif ext in ['.xlsx', '.xls']:
        try:
            df.to_excel(file_path, index=False)
            return f"Package summary saved to Excel file: {file_path}"
        except ImportError:
            print("Warning: openpyxl is required for Excel export. Installing it now...")
            subprocess.run([sys.executable, '-m', 'pip', 'install', 'openpyxl'], check=True)
            df.to_excel(file_path, index=False)
            return f"Package summary saved to Excel file: {file_path}"
    else:
        # Default to CSV if extension is not recognized
        csv_path = file_path + '.csv'
        df.to_csv(csv_path, index=False)
        return f"Package summary saved to CSV file: {csv_path}"

def main():
    # Get command line arguments
    output_format = 'markdown'  # Default format
    output_file = None
    
    if len(sys.argv) > 1:
        for i, arg in enumerate(sys.argv[1:], 1):
            if arg == '--format' and i < len(sys.argv):
                output_format = sys.argv[i+1]
            elif arg == '--output' and i < len(sys.argv):
                output_file = sys.argv[i+1]
            elif arg == '--excel':
                output_file = 'package_summary.xlsx'
            elif arg == '--csv':
                output_file = 'package_summary.csv'
    
    # Get installed packages
    packages = get_installed_packages()
    
    # Handle file output
    if output_file:
        result = save_to_file(packages, output_file)
        print(result)
    else:
        # Generate table for console display
        table = generate_summary_table(packages, output_format)
        print("\nInstalled Python Packages Summary:")
        print(table)

if __name__ == "__main__":
    main()