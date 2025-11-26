# Streamlit Project Init Script

This repo contains `init.sh`, a convenience script for setting up a Python virtual environment using [`uv`](https://github.com/astral-sh/uv) when available, with a pip/venv fallback.

## What the Script Does

- Prompts for the desired Python version (defaults to `3.10`) or accepts it as the first argument, e.g. `bash init.sh 3.11`.
- Detects whether `uv` is installed and offers to install it if missing.
- Creates `.venv` using `uv venv --python <version>` or `python<version> -m venv` when falling back to pip.
- Activates the virtual environment and initializes a new project via `uv init` (uv path) or creates a `requirements.txt` placeholder (pip path).

## Usage

```bash
chmod +x init.sh   # once
./init.sh          # interactively choose the Python version
# or
./init.sh 3.11     # non-interactive use
```

After the script finishes, the `.venv` folder contains the environment and the current shell session is already activated. Install additional dependencies with `uv add <pkg>` or `pip install -r requirements.txt`, depending on the path taken.
