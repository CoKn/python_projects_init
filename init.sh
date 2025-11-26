#!/bin/bash

set -euo pipefail

DEFAULT_PY_VERSION="3.10"
USER_SPECIFIED_VERSION="${1:-}"

if [[ -z "$USER_SPECIFIED_VERSION" ]]; then
    read -r -p "Specify Python version for the virtual environment [${DEFAULT_PY_VERSION}]: " USER_SPECIFIED_VERSION
fi

PYTHON_VERSION="${USER_SPECIFIED_VERSION:-$DEFAULT_PY_VERSION}"
echo "Using Python version: $PYTHON_VERSION"

resolve_python_interpreter() {
    local version="$1"
    local candidate="python${version}"

    if command -v "$candidate" >/dev/null 2>&1; then
        echo "$candidate"
        return 0
    fi

    echo "Python interpreter $candidate not found on PATH. Please install Python $version or update the PATH." >&2
    return 1
}

UV_AVAILABLE=0

if command -v uv >/dev/null 2>&1; then
    echo "uv detected: $(uv --version)"
    UV_AVAILABLE=1
else
    read -r -p "uv is not installed. Install it now? [y/N] " install_uv
    if [[ "$install_uv" =~ ^[Yy]$ ]]; then
        PY_CMD=""
        if command -v python3 >/dev/null 2>&1; then
            PY_CMD=python3
        elif command -v python >/dev/null 2>&1; then
            PY_CMD=python
        else
            echo "No python interpreter found to install uv." >&2
        fi

        if [[ -n "$PY_CMD" ]]; then
            echo "Installing uv via $PY_CMD -m pip ..."
            $PY_CMD -m pip install --user uv
        fi

        if command -v uv >/dev/null 2>&1; then
            echo "uv installation complete: $(uv --version)"
            UV_AVAILABLE=1
        else
            echo "uv installation failed; falling back to pip." >&2
        fi
    else
        echo "Continuing without uv; will fall back to pip." >&2
    fi
fi

if [[ "$UV_AVAILABLE" -eq 1 ]]; then
    echo "Proceeding with uv commands..."
    echo "Ensuring Python $PYTHON_VERSION is available via uv..."
    uv python install "$PYTHON_VERSION"
    uv venv --python "$PYTHON_VERSION" .venv
    echo "Virtual environment created with uv using Python $PYTHON_VERSION."

    source .venv/bin/activate

    # init project
    uv init

else
    echo "Falling back to pip commands..."
    PY_INTERPRETER=$(resolve_python_interpreter "$PYTHON_VERSION")
    echo "Creating virtual environment with $PY_INTERPRETER ..."
    "$PY_INTERPRETER" -m venv .venv
    echo "Virtual environment created with pip tooling using Python $PYTHON_VERSION."

    source .venv/bin/activate
    
    if [[ ! -f requirements.txt ]]; then
        echo "# Add project dependencies here" > requirements.txt
        echo "requirements.txt created in pip fallback path."
    else
        echo "requirements.txt already exists; leaving it untouched."
    fi

fi
