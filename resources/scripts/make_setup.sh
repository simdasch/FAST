#!/usr/bin/env bash

# shellcheck disable=SC2164
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
ROOT_DIR=${SCRIPT_DIR}/../../
POETRY_VERSION=1.4.1
POETRY_HOME="${HOME}/.local/poetry/${POETRY_VERSION}"

if [ -z "$1" ]
then
    echo "No conda environment name supplied."
    exit 1
fi
CONDA_ENV_NAME=$1
CONDA_ENV_DIR=$(conda info --base)/envs/$CONDA_ENV_NAME

# shellcheck disable=SC2164
cd "${ROOT_DIR}"

echo "---=== Create Conda environment ===---"
conda env create \
    -n "${CONDA_ENV_NAME}" \
    -f environment.yaml

echo "---=== Set POETRY_HOME=${POETRY_HOME} ===---"
conda env config vars set \
    POETRY_HOME=${POETRY_HOME} \
    -n "${CONDA_ENV_NAME}"

echo "---=== Set PATH=${PATH} ===---"
conda env config vars set \
    PATH=${CONDA_ENV_DIR}/bin:${PATH} \
    -n "${CONDA_ENV_NAME}"

# Ensure that pip can resolve macosx platform
echo "---=== Set SYSTEM_VERSION_COMPAT=0 for macos ===---"
conda env config vars set \
    SYSTEM_VERSION_COMPAT=0 \
    -n "${CONDA_ENV_NAME}"

if [ -d "$POETRY_HOME" ];
then
    echo "---=== Poetry ${POETRY_VERSION} alread exists in ${POETRY_HOME}. Skipping installation! ===---"
else
    echo "---=== Create isolated Poetry ${POETRY_VERSION} environment ===---"
    mkdir -p $POETRY_HOME
    conda run \
        --no-capture-output \
        -n "${CONDA_ENV_NAME}" \
        python3 -m venv ${POETRY_HOME}

    echo "---=== Install Poetry ${POETRY_VERSION} ===---"
    conda run \
        --no-capture-output \
        -n "${CONDA_ENV_NAME}" \
        $POETRY_HOME/bin/pip install poetry==$POETRY_VERSION
    
    echo "---=== Install keyrings.google-artifactregistry-auth for Dali Artifact Registry ===---"
    conda run \
        --no-capture-output \
        -n "${CONDA_ENV_NAME}" \
        $POETRY_HOME/bin/pip install "keyrings.google-artifactregistry-auth>=1.0.0"
fi

echo "---=== Set symlink for Poetry ${POETRY_VERSION} in current conda environment ===---"
conda run \
    --no-capture-output \
    -n "${CONDA_ENV_NAME}" \
    ln -sfn $POETRY_HOME/bin/poetry $CONDA_ENV_DIR/bin/poetry

echo "---=== Test whether Poetry ${POETRY_VERSION} is available ===---"
conda run \
    --no-capture-output \
    -n "${CONDA_ENV_NAME}" \
    poetry --version

echo "---=== Install dependencies with Poetry ${POETRY_VERSION} ===---"
conda run \
    --no-capture-output \
    -n "${CONDA_ENV_NAME}" \
    poetry install