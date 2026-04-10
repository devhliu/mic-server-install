#!/usr/bin/env bash

SCRIPT_VERSION="0.1.0"

needs_sudo() {
  local path="$1"
  local expanded_path
  
  expanded_path=$(eval echo "$path")
  
  if [[ "$expanded_path" == "$HOME"* ]] || [[ "$expanded_path" == "~"* ]]; then
    return 1
  fi
  
  local system_paths=("/opt" "/usr" "/usr/local" "/etc" "/var" "/local")
  for sys_path in "${system_paths[@]}"; do
    if [[ "$expanded_path" == "$sys_path"* ]]; then
      return 0
    fi
  done
  
  return 0
}

run_cmd() {
  local use_sudo="$1"
  shift
  
  if [ "$use_sudo" = "true" ]; then
    sudo "$@"
  else
    "$@"
  fi
}

get_install_dir() {
  local default_dir="$1"
  local custom_dir="${INSTALL_DIR:-}"
  
  if [ -n "$custom_dir" ]; then
    echo "$custom_dir"
  else
    echo "$default_dir"
  fi
}

get_profile_file() {
  local install_dir="$1"
  local profile_name="$2"
  
  if needs_sudo "$install_dir"; then
    echo "/etc/profile.d/${profile_name}"
  else
    local profile_dir="$HOME/.profile.d"
    mkdir -p "$profile_dir"
    echo "$profile_dir/${profile_name}"
  fi
}

insert_text() {
  local search_string="$1"
  local insert_string="$2"
  local filepath="$3"
  local use_sudo="${4:-auto}"
  
  if [ "$use_sudo" = "auto" ]; then
    if needs_sudo "$filepath"; then
      use_sudo="true"
    else
      use_sudo="false"
    fi
  fi
  
  if [ "$use_sudo" = "true" ]; then
    if ! sudo [ -f "$filepath" ]; then
      echo "Error: $filepath does not exist!" >&2
      return 1
    fi
    
    if sudo grep -qF "$search_string" "$filepath"; then
      echo "Skipped: '$insert_string' already exists in $filepath"
      return 0
    else
      echo "Adding: '$insert_string' to $filepath"
      sudo sh -c "echo '$insert_string' >> '$filepath'"
      return 0
    fi
  else
    if [ ! -f "$filepath" ]; then
      echo "Error: $filepath does not exist!" >&2
      return 1
    fi
    
    if grep -qF "$search_string" "$filepath"; then
      echo "Skipped: '$insert_string' already exists in $filepath"
      return 0
    else
      echo "Adding: '$insert_string' to $filepath"
      echo "$insert_string" >> "$filepath"
      return 0
    fi
  fi
}
