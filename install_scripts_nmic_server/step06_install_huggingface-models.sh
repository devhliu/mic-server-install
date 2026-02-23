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
    echo "Download models or specific files from Hugging Face Hub"
    echo ""
    echo "Options:"
    echo "  -t, --token TOKEN       Hugging Face API token (or set HF_TOKEN env var)"
    echo "  -m, --model MODEL       Model name in format 'org/model-name' (for full repo download)"
    echo "  -f, --file FILE_PATH    Download a specific file in format 'org/model/file'"
    echo "                          Example: 'mterris/ram/ram.pth.tar' or 'mterris/ram/resolve/main/ram.pth.tar'"
    echo "  -o, --output DIR        Output directory (default: ./models)"
    echo "  -r, --revision REVISION Model revision/branch (default: main)"
    echo "  --mirror                Use China mirror (hf-mirror.com) [default]"
    echo "  --original              Use original Hugging Face source"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Mirror Sources:"
    echo "  China mirror (default): ${HF_MIRROR_URL}"
    echo "  Original source:        ${HF_ORIGINAL_URL}"
    echo ""
    echo "Examples:"
    echo "  # Download entire model repository"
    echo "  $0 -t hf_xxx -m bert-base-uncased"
    echo "  $0 -t hf_xxx -m meta-llama/Llama-2-7b-hf -o ./llama-models"
    echo ""
    echo "  # Download a specific file"
    echo "  $0 -t hf_xxx -f mterris/ram/ram.pth.tar"
    echo "  $0 -f mterris/ram/resolve/main/ram.pth.tar"
    echo "  $0 -f openai/clip-vit-base-patch32/pytorch_model.bin -o ./weights"
    echo ""
    echo "  # Use original source instead of mirror"
    echo "  $0 -t hf_xxx -m bert-base-uncased --original"
    echo ""
    echo "Environment Variables:"
    echo "  HF_TOKEN    Hugging Face API token"
    echo "  HF_TOKEN=hf_xxx $0 -m bert-base-uncased"
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

print(f'Starting download (Attempt $((retry_count+1))/${max_retries}): {model_name}')
local_dir = os.path.join(output_dir, model_name.replace('/', '_'))
snapshot_download(
    repo_id=model_name,
    revision=revision,
    local_dir=local_dir,
    token=token,
    endpoint=endpoint,
    resume_download=True
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
print(f'Attempt:   $((retry_count+1))/${max_retries}')

local_path = hf_hub_download(
    repo_id=repo_id,
    filename=filename,
    revision=revision,
    local_dir=output_dir,
    token=token,
    endpoint=endpoint,
    resume_download=True
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
    
    check_dependencies
    
    if [[ -n "${FILE_PATH}" ]]; then
        download_file "${FILE_PATH}" "${OUTPUT_DIR}" "${USE_MIRROR}"
    else
        download_model "${MODEL_NAME}" "${OUTPUT_DIR}" "${REVISION}" "${USE_MIRROR}"
    fi
}

main "$@"
