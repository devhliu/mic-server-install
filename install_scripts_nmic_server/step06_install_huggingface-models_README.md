# Install/Download Hugging Face Models

This script provides a flexible way to download models or specific files from Hugging Face, with support for using a Chinese mirror (`hf-mirror.com`) to accelerate downloads.

## Overview of Changes
The script uses the `huggingface_hub` Python library to perform downloads.
1.  **Dependency Check**: Checks for `python3` and installs `huggingface_hub[cli]` if it's missing.
2.  **Download**: Uses `snapshot_download` (for full models) or `hf_hub_download` (for specific files) to fetch content.
3.  **Mirror Support**: Defaults to using `hf-mirror.com` for faster access in China, but can be switched to the original source.

## Prerequisites
- **Python 3**: Required to run.
- **Hugging Face Token**: Optional, but recommended for accessing gated models.
- **Network Connection**: Required.

## Usage

The script accepts several arguments to control the download process.

### Basic Usage
```bash
./step06_install_huggingface-models.sh -m <org/model-name>
```

### Options
- `-t, --token TOKEN`: Hugging Face API token.
- `-m, --model MODEL`: Model ID (e.g., `meta-llama/Llama-2-7b-hf`).
- `-f, --file FILE_PATH`: Specific file path to download (format: `repo_id/filename`).
- `-o, --output DIR`: Output directory (default: `./models`).
- `-r, --revision REVISION`: Model revision/branch (default: `main`).
- `--mirror`: Use `hf-mirror.com` (Default).
- `--original`: Use `huggingface.co`.

### Examples

**Download a full model repo:**
```bash
./step06_install_huggingface-models.sh -t your_token -m bert-base-uncased
```

**Download a specific file:**
```bash
./step06_install_huggingface-models.sh -f openai/clip-vit-base-patch32/pytorch_model.bin -o ./weights
```
