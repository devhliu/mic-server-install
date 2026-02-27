# Install/Download Hugging Face Models

This script provides a robust and flexible way to download models or specific files from Hugging Face Hub, with automatic retry logic, mirror support, and input validation.

## Overview

The script uses the `huggingface_hub` Python library to perform downloads with the following features:

1. **Automatic Retry Logic**: 5 retry attempts with 10-second delays for failed downloads
2. **Mirror Support**: Defaults to Chinese mirror (`hf-mirror.com`) for faster access in China
3. **Input Validation**: Validates model names and file path formats before downloading
4. **Flexible Options**: Support for both full model repositories and specific files
5. **Error Handling**: Comprehensive error messages and validation checks

## Prerequisites

- **Python 3**: Required to run the script
- **Hugging Face Token**: Optional, required for private/gated models
- **Network Connection**: Required for downloading models
- **pip**: For installing the huggingface_hub package if missing

## Installation

The script will automatically install the required Python package if missing:

```bash
# The script will install huggingface_hub[cli] if not present
pip install huggingface_hub[cli]
```

## Usage

### Basic Syntax
```bash
./step06_install_huggingface-models.sh [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --token TOKEN` | Hugging Face API token (for private/gated models) | - |
| `-m, --model MODEL` | Model name in format `org/model-name` | - |
| `-f, --file FILE_PATH` | Specific file path in format `org/repo/file` | - |
| `-o, --output DIR` | Output directory | `./models` |
| `-r, --revision REVISION` | Model revision/branch/tag | `main` |
| `--mirror` | Use China mirror (`hf-mirror.com`) | Enabled |
| `--original` | Use original Hugging Face source (`huggingface.co`) | - |
| `-h, --help` | Show help message | - |

### Environment Variables

You can also set defaults using environment variables:

```bash
export HF_TOKEN=your_token_here
export MODEL_NAME=your/model
export OUTPUT_DIR=./my-models
export REVISION=main
export USE_MIRROR=true  # or false for original source
```

## Examples

### Download Entire Model Repository

```bash
# Basic model download
./step06_install_huggingface-models.sh -m bert-base-uncased

# Download to custom directory
./step06_install_huggingface-models.sh -m meta-llama/Llama-2-7b-hf -o ./llama-models

# With authentication token
./step06_install_huggingface-models.sh -t hf_xxx -m microsoft/DialoGPT-medium

# Use original Hugging Face source
./step06_install_huggingface-models.sh -m bert-base-uncased --original
```

### Download Specific Files

```bash
# Download specific file
./step06_install_huggingface-models.sh -f mterris/ram/ram.pth.tar

# Download file with specific revision
./step06_install_huggingface-models.sh -f mterris/ram/resolve/main/ram.pth.tar -o ./checkpoints

# Download model configuration file
./step06_install_huggingface-models.sh -f openai/clip-vit-base-patch32/pytorch_model.bin

# Download with authentication
./step06_install_huggingface-models.sh -t hf_xxx -f stabilityai/stable-diffusion-2/config.json
```

## Input Validation

The script validates inputs before downloading:

- **Model Names**: Must match format `org/repo` (e.g., `bert-base-uncased` or `meta-llama/Llama-2-7b-hf`)
- **File Paths**: Must match format `org/repo/file` or `org/repo/resolve/revision/file`
- **Output Directory**: Automatically created if it doesn't exist

## Error Handling

The script includes comprehensive error handling:

- **Validation Errors**: Clear error messages with examples for incorrect formats
- **Download Failures**: Automatic retry with progress reporting
- **Dependency Issues**: Automatic installation of missing Python packages
- **Permission Issues**: Error messages for directory creation problems

## Mirror Support

By default, the script uses the Chinese mirror (`hf-mirror.com`) for faster downloads in China. You can switch to the original Hugging Face source using the `--original` flag.

**Mirror URLs:**
- China Mirror: `https://hf-mirror.com` (default)
- Original Source: `https://huggingface.co`

## Troubleshooting

### Common Issues

1. **Python Not Found**: Install Python 3 and ensure it's in PATH
2. **Permission Denied**: Check write permissions for output directory
3. **Network Issues**: The script will automatically retry failed downloads
4. **Invalid Model Name**: Use the correct format `org/model-name`

### Debug Mode

For debugging, you can run with `set -x`:

```bash
bash -x ./step06_install_huggingface-models.sh -m bert-base-uncased
```

## Related Scripts

This script is part of a larger installation suite. See other step scripts for additional functionality.

## Changelog

### Recent Improvements
- Fixed Python variable expansion issues in retry messages
- Added comprehensive input validation for model names and file paths
- Improved error messages with examples and suggestions
- Enhanced documentation with better examples and usage patterns
- Added automatic output directory creation
- Improved mirror switching functionality

## License

This script is provided as part of the MIC Server installation suite.