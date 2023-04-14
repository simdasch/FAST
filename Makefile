SHELL := /bin/bash
conda_env_name=FAST

export PYTHONPATH=$(shell pwd)
export CONDA_ENV_NAME=${conda_env_name}

define execute_in_env
	source activate ${CONDA_ENV_NAME}; \
	$1
endef

setup:
	resources/scripts/make_setup.sh ${CONDA_ENV_NAME}

