#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# This code was generated by the DevContainers Feature Cookiecutter
# Docs: https://github.com/devcontainers-contrib/features/tree/main/pkgs/feature-template#readme
#-------------------------------------------------------------------------------------------------------------

set -e

# asdf plugin version for elixir
ELIXIR=${ELIXIRVERSION:-"latest"}
# asdf plugin version for erlang
ERLANG=${ERLANGVERSION:-"latest"}

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as 
    root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

check_packages() {
	# This is part of devcontainers-contrib script library
	# source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
	if ! dpkg -s "$@" >/dev/null 2>&1; then
		if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
			echo "Running apt-get update..."
			apt-get update -y
		fi
		apt-get -y install --no-install-recommends "$@"
	fi
}

aptget_packages=(build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk)
check_packages "${aptget_packages[@]}"

updaterc() {
	# This is part of devcontainers-contrib script library
	# source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
	echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
	if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
		echo -e "$1" >>/etc/bash.bashrc
	fi
	if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
		echo -e "$1" >>/etc/zsh/zshrc
	fi
}

install_via_asdf() {
	# This is part of devcontainers-contrib script library
	# source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
	PACKAGE=$1
	VERSION=$2
	REPO=$3

	# install git and curl if does not exists
	check_packages curl git
	if ! type asdf >/dev/null 2>&1; then
		su - "$_REMOTE_USER" <<EOF
            git clone --depth=1 \
            -c core.eol=lf \
            -c core.autocrlf=false \
            -c fsck.zeroPaddedFilemode=ignore \
            -c fetch.fsck.zeroPaddedFilemode=ignore \
            -c receive.fsck.zeroPaddedFilemode=ignore \
            "https://github.com/asdf-vm/asdf.git" $_REMOTE_USER_HOME/.asdf 2>&1
            . $_REMOTE_USER_HOME/.asdf/asdf.sh

            asdf plugin-add "$PACKAGE" "$REPO"
            asdf install "$PACKAGE" "$VERSION"
            asdf global "$PACKAGE" "$VERSION"
EOF
	fi
	updaterc ". $_REMOTE_USER_HOME/.asdf/asdf.sh"
}

if [ "$ELIXIR" != "none" ]; then
	install_via_asdf "elixir" "$ELIXIR"
fi
if [ "$ERLANG" != "none" ]; then
	install_via_asdf "erlang" "$ERLANG"
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
