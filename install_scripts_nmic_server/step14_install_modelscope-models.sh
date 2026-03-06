#!/bin/bash

set -e

MODEL_NAME="${MODEL_NAME:-}"
OUTPUT_DIR="${OUTPUT_DIR:-./models}"
REVISION="${REVISION:-master}"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Download models from ModelScope Hub"
    echo ""
    echo "Options:"
    echo "  -m, --model MODEL       Model name in format 'org/model-name'"
    echo "  -o, --output DIR        Output directory (default: ./models)"
    echo "  -r, --revision REVISION Model revision/branch (default: master)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Download model repository"
    echo "  $0 -m damo/nlp_structbert_sentence-similarity_chinese-base"
    echo "  $0 -m ZhipuAI/chatglm3-6b -o ./chatglm-models"
    echo ""
    echo "Environment Variables:"
    echo "  MODEL_NAME    ModelScope model name"
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--model)
                MODEL_NAME="$2"
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
    
    if ! python3 -c "import modelscope" 2>/dev/null; then
        echo "Installing modelscope package..."
        pip install modelscope -q
    fi
}

download_model() {
    local model_name="$1"
    local output_dir="$2"
    local revision="$3"
    
    echo "=========================================="
    echo "Downloading ModelScope Model"
    echo "=========================================="
    echo "Model:     ${model_name}"
    echo "Revision:  ${revision}"
    echo "Output:    ${output_dir}"
    echo "=========================================="
    
    mkdir -p "${output_dir}"
    
    local max_retries=5
    local retry_count=0
    local success=false

    while [ $retry_count -lt $max_retries ]; do
        if python3 -c "
from modelscope.hub.snapshot_download import snapshot_download
import os
import sys

model_name = '${model_name}'
output_dir = '${output_dir}'
revision = '${revision}'

print(f'Starting download (Attempt $((retry_count+1))/${max_retries}): {model_name}')
try:
    # ModelScope snapshot_download uses cache_dir to specify the root download directory
    # The actual model will be in cache_dir/model_name
    model_dir = snapshot_download(
        model_id=model_name,
        revision=revision,
        cache_dir=output_dir
    )
    print(f'Model downloaded to: {model_dir}')
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
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

# Main execution
parse_args "$@"

if [[ -z "${MODEL_NAME}" ]]; then
    echo "Error: Model name is required."
    usage
fi

check_dependencies
download_model "${MODEL_NAME}" "${OUTPUT_DIR}" "${REVISION}"
