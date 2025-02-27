#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# This code was generated by the DevContainers Feature Cookiecutter
# Docs: https://github.com/devcontainers-contrib/features/tree/main/pkgs/feature-template#readme
#-------------------------------------------------------------------------------------------------------------

set -e

# pipx version for gdbgui
GDBGUI=${VERSION:-"latest"}

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as 
    root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

install_via_pipx() {
	# This is part of devcontainers-contrib script library
	# source: https://github.com/devcontainers-contrib/features/tree/v1.1.6/script-library
	PACKAGES=("$@")
	arraylength="${#PACKAGES[@]}"

	env_name=$(echo ${PACKAGES[0]} | cut -d "=" -f 1 | cut -d "<" -f 1 | cut -d ">" -f 1)

	# if no python - install it
	if ! dpkg -s python3-minimal python3-pip libffi-dev python3-venv >/dev/null 2>&1; then
		apt-get update -y
		apt-get -y install python3-minimal python3-pip libffi-dev python3-venv
	fi
	export PIPX_HOME=/usr/local/pipx
	mkdir -p ${PIPX_HOME}
	export PIPX_BIN_DIR=/usr/local/bin
	export PYTHONUSERBASE=/tmp/pip-tmp
	export PIP_CACHE_DIR=/tmp/pip-tmp/cache
	pipx_bin=pipx
	# if pipx not exists - install it
	if ! type pipx >/dev/null 2>&1; then
		pip3 install --disable-pip-version-check --no-cache-dir --user pipx packaging==21.3
		pipx_bin=/tmp/pip-tmp/bin/pipx
	fi
	# install main package
	${pipx_bin} install --pip-args '--no-cache-dir --force-reinstall' -f "${PACKAGES[0]}"
	# install injections (if provided)
	for ((i = 1; i < ${arraylength}; i++)); do
		${pipx_bin} inject $env_name --pip-args '--no-cache-dir --force-reinstall' -f "${PACKAGES[$i]}"
	done

	# cleaning pipx to save disk space
	rm -rf /tmp/pip-tmp
}

pipx_installations=()
if [ "$GDBGUI" != "none" ]; then
	if [ "$GDBGUI" = "latest" ]; then
		pipx_installations+=("gdbgui")
	else
		pipx_installations+=("gdbgui==$GDBGUI")
	fi
fi

install_via_pipx "${pipx_installations[@]}"

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
