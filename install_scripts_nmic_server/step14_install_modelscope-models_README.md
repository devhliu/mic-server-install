# Install/Download ModelScope Models

This script provides a convenient way to download models from ModelScope Hub using the `modelscope` Python package. ModelScope is optimized for access within China, so no additional mirror settings are required.

## Overview
The script uses the `modelscope` library to perform downloads.
1.  **Dependency Check**: Checks for `python3` and installs `modelscope` if it's missing.
2.  **Download**: Uses `snapshot_download` to fetch full model repositories.
3.  **Local Storage**: Models are downloaded to the specified output directory (defaults to `./models`).

## Prerequisites
- **Python 3**: Required to run the script.
- **pip**: Required to install the `modelscope` package.
- **Network Connection**: Required to access ModelScope Hub.

## Usage

The script accepts several arguments to control the download process.

### Basic Usage
```bash
./step12_install_modelscope-models.sh -m <org/model-name>
```

### Options
- `-m, --model MODEL`: Model ID on ModelScope (e.g., `ZhipuAI/chatglm3-6b`).
- `-o, --output DIR`: Output directory where the model will be stored (default: `./models`).
- `-r, --revision REVISION`: Model revision/branch (default: `master`).
- `-h, --help`: Show the help message.

### Examples

**Download a model repo:**
```bash
./step12_install_modelscope-models.sh -m ZhipuAI/chatglm3-6b
```

**Download to a specific directory:**
```bash
./step12_install_modelscope-models.sh -m damo/nlp_structbert_sentence-similarity_chinese-base -o ./my_models
```

**Download a specific revision:**
```bash
./step12_install_modelscope-models.sh -m ZhipuAI/chatglm3-6b -r v1.0.0
```

## Environment Variables
- `MODEL_NAME`: Can be set instead of using the `-m` flag.
