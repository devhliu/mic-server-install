#!/bin/bash

set -e

HF_TOKEN="${HF_TOKEN:-}"
MODEL_NAME="${MODEL_NAME:-}"
FILE_PATH="${FILE_PATH:-}"
OUTPUT_DIR="${OUTPUT_DIR:-./models}"
REVISION="${REVISION:-main}"
USE_MIRROR="${USE_MIRROR:-true}"

HF_MIRROR_URL="https://hf-mirror.com"
HF_ORIGINAL_URL="https://huggingface.co"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Download models or specific files from Hugging Face Hub with automatic retry and mirror support"
    echo ""
    echo "Options:"
    echo "  -t, --token TOKEN       Hugging Face API token (required for private/gated models)"
    echo "                          Alternatively, set HF_TOKEN environment variable"
    echo "  -m, --model MODEL       Model name in format 'org/model-name' (downloads entire repository)"
    echo "  -f, --file FILE_PATH    Download specific file in format 'org/repo/file' or"
    echo "                          'org/repo/resolve/revision/file' for specific revisions"
    echo "  -o, --output DIR        Output directory (default: ./models)"
    echo "  -r, --revision REVISION Model revision/branch/tag (default: main)"
    echo "  --mirror                Use China mirror (hf-mirror.com) [default for better China access]"
    echo "  --original              Use original Hugging Face source (huggingface.co)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Mirror Sources:"
    echo "  China mirror (default): ${HF_MIRROR_URL}"
    echo "  Original source:        ${HF_ORIGINAL_URL}"
    echo ""
    echo "Examples:"
    echo "  # Download entire model repository"
    echo "  $0 -m bert-base-uncased"
    echo "  $0 -m meta-llama/Llama-2-7b-hf -o ./llama-models"
    echo "  $0 -t hf_xxx -m microsoft/DialoGPT-medium"
    echo ""
    echo "  # Download specific files"
    echo "  $0 -f mterris/ram/ram.pth.tar"
    echo "  $0 -f mterris/ram/resolve/main/ram.pth.tar -o ./checkpoints"
    echo "  $0 -f openai/clip-vit-base-patch32/pytorch_model.bin"
    echo "  $0 -t hf_xxx -f stabilityai/stable-diffusion-2/config.json"
    echo ""
    echo "  # Use different sources"
    echo "  $0 -m bert-base-uncased --original"
    echo "  $0 -f mterris/ram/ram.pth.tar --mirror"
    echo ""
    echo "Environment Variables:"
    echo "  HF_TOKEN        Hugging Face API token for authentication"
    echo "  MODEL_NAME      Default model name (overridden by -m)"
    echo "  FILE_PATH       Default file path (overridden by -f)"
    echo "  OUTPUT_DIR      Default output directory (overridden by -o)"
    echo "  REVISION        Default revision (overridden by -r)"
    echo "  USE_MIRROR      Set to 'false' to use original source (default: true)"
    echo ""
    echo "Note: The script automatically retries failed downloads (5 attempts with 10s delays)"
    echo "      and validates input formats before proceeding."
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--token)
                HF_TOKEN="$2"
                shift 2
                ;;
            -m|--model)
                MODEL_NAME="$2"
                shift 2
                ;;
            -f|--file)
                FILE_PATH="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -r|--revision)
                REVISION="$2"
                shift 2
                ;;
            --mirror)
                USE_MIRROR="true"
                shift
                ;;
            --original)
                USE_MIRROR="false"
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Unknown option: $1"
                usage
                ;;
        esac
    done
}

check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is required but not installed."
        exit 1
    fi
    
    if ! python3 -c "import huggingface_hub" 2>/dev/null; then
        echo "Installing huggingface_hub package..."
        pip install huggingface_hub[cli] -q
    fi
}

validate_inputs() {
    if [[ -n "${MODEL_NAME}" ]]; then
        # Validate model name format (org/repo)
        if [[ ! "${MODEL_NAME}" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+$ ]]; then
            echo "Error: Invalid model name format. Expected: org/repo, got: ${MODEL_NAME}"
            echo "Example: bert-base-uncased or meta-llama/Llama-2-7b-hf"
            exit 1
        fi
    fi
    
    if [[ -n "${FILE_PATH}" ]]; then
        # Validate file path format (org/repo/file or org/repo/resolve/revision/file)
        if [[ ! "${FILE_PATH}" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+(/[a-zA-Z0-9._-]+)*$ ]]; then
            echo "Error: Invalid file path format. Expected: org/repo/file or org/repo/resolve/revision/file"
            echo "Example: mterris/ram/ram.pth.tar or mterris/ram/resolve/main/ram.pth.tar"
            exit 1
        fi
    fi
    
    # Validate output directory
    if [[ ! -d "${OUTPUT_DIR}" ]]; then
        mkdir -p "${OUTPUT_DIR}" || {
            echo "Error: Cannot create output directory: ${OUTPUT_DIR}"
            exit 1
        }
    fi
}

download_model() {
    local model_name="$1"
    local output_dir="$2"
    local revision="$3"
    local use_mirror="$4"
    
    local endpoint=""
    if [[ "${use_mirror}" == "true" ]]; then
        endpoint="${HF_MIRROR_URL}"
        echo "Using China mirror: ${endpoint}"
    else
        endpoint="${HF_ORIGINAL_URL}"
        echo "Using original source: ${endpoint}"
    fi
    
    echo "=========================================="
    echo "Downloading Hugging Face Model"
    echo "=========================================="
    echo "Model:     ${model_name}"
    echo "Revision:  ${revision}"
    echo "Output:    ${output_dir}"
    echo "Endpoint:  ${endpoint}"
    echo "=========================================="
    
    mkdir -p "${output_dir}"
    
    local max_retries=5
    local retry_count=0
    local success=false

    while [ $retry_count -lt $max_retries ]; do
        if python3 -c "
from huggingface_hub import snapshot_download
import os

model_name = '${model_name}'
output_dir = '${output_dir}'
revision = '${revision}'
token = '${HF_TOKEN}' if '${HF_TOKEN}' else None
endpoint = '${endpoint}'
retry_count = ${retry_count}
max_retries = ${max_retries}

print(f'Starting download (Attempt {retry_count+1}/{max_retries}): {model_name}')
local_dir = os.path.join(output_dir, model_name.replace('/', '_'))
snapshot_download(
    repo_id=model_name,
    revision=revision,
    local_dir=local_dir,
    token=token,
    endpoint=endpoint
)
print(f'Model downloaded to: {local_dir}')
"; then
            success=true
            break
        else
            echo "Download failed. Retrying in 10 seconds... ($((retry_count+1))/$max_retries)"
            sleep 10
            retry_count=$((retry_count+1))
        fi
    done

    if [ "$success" = false ]; then
        echo "Failed to download model after $max_retries attempts."
        exit 1
    fi
    
    echo "=========================================="
    echo "Download completed successfully!"
    echo "=========================================="
}

download_file() {
    local file_path="$1"
    local output_dir="$2"
    local use_mirror="$3"
    
    local endpoint=""
    if [[ "${use_mirror}" == "true" ]]; then
        endpoint="${HF_MIRROR_URL}"
        echo "Using China mirror: ${endpoint}"
    else
        endpoint="${HF_ORIGINAL_URL}"
        echo "Using original source: ${endpoint}"
    fi
    
    echo "=========================================="
    echo "Downloading Hugging Face File"
    echo "=========================================="
    echo "File path: ${file_path}"
    echo "Output:    ${output_dir}"
    echo "Endpoint:  ${endpoint}"
    echo "=========================================="
    
    mkdir -p "${output_dir}"
    
    local max_retries=5
    local retry_count=0
    local success=false

    while [ $retry_count -lt $max_retries ]; do
        if python3 -c "
from huggingface_hub import hf_hub_download
import os
import re

file_path = '${file_path}'
output_dir = '${output_dir}'
token = '${HF_TOKEN}' if '${HF_TOKEN}' else None
endpoint = '${endpoint}'
retry_count = ${retry_count}
max_retries = ${max_retries}

parts = file_path.split('/')
if len(parts) < 3:
    raise ValueError(f'Invalid file path format. Expected: org/repo/filename or org/repo/revision/filename, got: {file_path}')

if 'resolve' in parts:
    resolve_idx = parts.index('resolve')
    repo_id = '/'.join(parts[:resolve_idx])
    filename = '/'.join(parts[resolve_idx+2:])
    revision = parts[resolve_idx+1]
else:
    repo_id = '/'.join(parts[:2])
    filename = '/'.join(parts[2:])
    revision = 'main'

print(f'Repo ID:   {repo_id}')
print(f'Filename:  {filename}')
print(f'Revision:  {revision}')
print(f'Attempt:   {retry_count+1}/{max_retries}')

local_path = hf_hub_download(
    repo_id=repo_id,
    filename=filename,
    revision=revision,
    local_dir=output_dir,
    token=token,
    endpoint=endpoint
)
print(f'File downloaded to: {local_path}')
"; then
            success=true
            break
        else
            echo "Download failed. Retrying in 10 seconds... ($((retry_count+1))/$max_retries)"
            sleep 10
            retry_count=$((retry_count+1))
        fi
    done

    if [ "$success" = false ]; then
        echo "Failed to download file after $max_retries attempts."
        exit 1
    fi
    
    echo "=========================================="
    echo "Download completed successfully!"
    echo "=========================================="
}

main() {
    parse_args "$@"
    
    if [[ -z "${MODEL_NAME}" && -z "${FILE_PATH}" ]]; then
        echo "Error: Either model name (-m) or file path (-f) is required."
        usage
    fi
    
    validate_inputs
    check_dependencies
    
    if [[ -n "${FILE_PATH}" ]]; then
        download_file "${FILE_PATH}" "${OUTPUT_DIR}" "${USE_MIRROR}"
    else
        download_model "${MODEL_NAME}" "${OUTPUT_DIR}" "${REVISION}" "${USE_MIRROR}"
    fi
}

main "$@"
