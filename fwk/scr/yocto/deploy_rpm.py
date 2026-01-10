#!/usr/bin/env python3

"""
    Deploys a rpm package on the target.

    Usage:  deploy_rpm.py <package> <hostname>

    <package> can be either a full path to a rpm, or the BitBake recipe name.
    In the latter case, the script uses BitBake to determine the name and location of the package.
    The package is then scp'ed to the target and installed via dnf.
"""

import sys
import subprocess
import os
import re
from pathlib import Path


def run_command(command):
    """Runs a shell command and returns the output."""
    result = subprocess.run(command, shell=True, text=True, capture_output=True)
    if result.returncode != 0:
        print(f"Error: Command '{command}' failed!", file=sys.stderr)
        sys.exit(1)
    return result.stdout.strip()


def extract_value(output, key):
    """Extracts a value from the bitbake environment log output."""
    for line in output.splitlines():
        match = re.match(fr'^{key}="(.*?)"', line)
        if match:
            return match.group(1)
    print(f"Error: {key} not found in bitbake output", file=sys.stderr)
    sys.exit(1)


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <package> <hostname>", file=sys.stderr)
        sys.exit(1)
    
    package_name = sys.argv[1]
    target_host = sys.argv[2]
    
    if "/" in package_name:
        package_file = package_name
    else:
        print(f"Determining package file for {package_name}...")
        
        bitbake_cmd = f"bitbake -e {package_name}"
        bitbake_output = run_command(bitbake_cmd)
        
        deploy_dir = extract_value(bitbake_output, "DEPLOY_DIR_RPM")
        package_arch = extract_value(bitbake_output, "PACKAGE_ARCH").replace('-', '_')
        package_basename = extract_value(bitbake_output, "PF")
        
        pkg_base = Path(deploy_dir) / package_arch / package_basename
        print(f"Looking for {pkg_base}*")
        
        matching_files = list(pkg_base.parent.glob(f"{pkg_base.name}*"))
        
        if len(matching_files) != 1:
            print(f"Error: Expected exactly one match, but found {len(matching_files)}.", file=sys.stderr)
            sys.exit(1)
        
        package_file = str(matching_files[0])
    
    print(f"Using package file: {package_file}")
    remote_path = f"/tmp/{os.path.basename(package_file)}"
    
    if not os.path.isfile(package_file):
        print(f"Error: Package file '{package_file}' not found!", file=sys.stderr)
        sys.exit(1)
    
    print(f"Copying package to target: {target_host}...")
    if subprocess.run(["scp", package_file, f"root@{target_host}:{remote_path}"], check=False).returncode != 0:
        print("Error: Failed to copy package to target.", file=sys.stderr)
        sys.exit(1)
    
    print("Installing package on target via DNF...")
    install_cmd = f"ssh root@{target_host} 'dnf install --cacheonly -y {remote_path} && rm -f {remote_path}'"
    if subprocess.run(install_cmd, shell=True, check=False).returncode == 0:
        print("Installation successful!")
    else:
        print("Error: Installation failed!", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

