#!/bin/bash
# A script to set up a new Ubuntu system.
# To run: sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup.sh)"

DOTFILES_REPO="https://github.com/ryanschuhler/system-setup.git"
DOTFILES_DIR="${HOME}/repos/system-setup"
SYSTEM_PACKAGES="
	btop
	ant
	build-essential
	ca-certificates
	curl
	git
	jq
	rsync
	nodejs
	openvpn
	python3
	python3-pip
	tig
	tmux
	tree
	unzip
	vim
	wakeonlan
	wget
	zsh"

_info() {
	echo -e "\033[1;34m[INFO]\033[0m ${1}"
}

_install_deb_package() {
	local package_name="$1"
	local package_url="$2"
	local package_file="${package_name}.deb"

	if command -v "${package_name}" >/dev/null 2>&1; then
		_info "${package_name} is already installed."
		return
	fi

	_info "Installing ${package_name}..."
	curl -L "${package_url}" -o "${package_file}"
	
	if dpkg -i "${package_file}"; then
		_info "${package_name} installed successfully."
	else
		_warn "${package_name} installation failed. Attempting to fix dependencies..."
		apt-get install -f -y
	fi
	rm "${package_file}"
}

_warn() {
	echo -e "\033[1;33m[WARN]\033[0m ${1}"
}

check_root() {
	if [ "${EUID}" -ne 0 ]; then
		echo "Please run this script with sudo or as root."
		exit 1
	fi
}

clone_dotfiles_repo() {
	_info "Cloning dotfiles repository..."
	if [ -d "${DOTFILES_DIR}" ]; then
		_warn "Dotfiles directory already exists. Skipping clone."
	else
		git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"
	fi
}

install_1password() {
	if command -v 1password >/dev/null 2>&1 && command -v op >/dev/null 2>&1; then
		_info "1Password and 1Password CLI are already installed."
		return
	fi
	_info "Installing 1Password and 1Password CLI..."
	curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | tee /etc/apt/sources.list.d/1password.list > /dev/null

	apt-get update
	apt-get install -y 1password 1password-cli
	_info "1Password and 1Password CLI installed."
}

install_bitwarden() {
	_info "Installing Bitwarden..."
	local bitwarden_url
	bitwarden_url=$(curl -s "https://api.github.com/repos/bitwarden/clients/releases/latest" | grep "browser_download_url.*desktop.*amd64.deb" | cut -d '"' -f 4)
	
	if [ -n "${bitwarden_url}" ]; then
		_install_deb_package "bitwarden" "${bitwarden_url}"
	else
		_warn "Could not determine latest Bitwarden .deb package. Skipping."
	fi
}

install_docker() {
	if command -v docker >/dev/null 2>&1; then
		_info "Docker is already installed."
	else
		_info "Installing Docker using the convenience script..."
		curl -fsSL https://get.docker.com -o get-docker.sh
		sh get-docker.sh
		rm get-docker.sh
		_info "Docker installed."
	fi

	_info "Configuring Docker to run without sudo..."
	groupadd --force docker
	usermod -aG docker "$(logname)"
	_info "User '$(logname)' added to the docker group. You will need to log out and back in for this to take effect."
}

install_gh() {
	if command -v gh >/dev/null 2>&1; then
		_info "GitHub CLI (gh) is already installed."
		return
	fi
	_info "Installing GitHub CLI (gh)..."
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	apt-get update
	apt-get install -y gh
	_info "GitHub CLI (gh) installed."
}

install_k8s_tools() {
	_info "Installing Kubernetes tools (k3s, Helm, Stern, k9s)..."
	
	if command -v k3s >/dev/null 2>&1; then
		_info "k3s is already installed."
	else
		curl -sfL https://get.k3s.io | sh -
		_info "k3s master installed. Find the node token at /var/lib/rancher/k3s/server/node-token"
	fi

	if command -v helm >/dev/null 2>&1; then
		_info "Helm is already installed."
	else
		curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
	fi

	if command -v stern >/dev/null 2>&1; then
		_info "Stern is already installed."
	else
		local STERN_LATEST_URL
		STERN_LATEST_URL=$(curl -s "https://api.github.com/repos/stern/stern/releases/latest" | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d '"' -f 4)
		if [ -n "${STERN_LATEST_URL}" ]; then
			curl -Lo stern.tar.gz "${STERN_LATEST_URL}"
			tar -xvf stern.tar.gz stern
			mv stern /usr/local/bin/stern
			rm stern.tar.gz
			_info "Stern installed."
		else
			_warn "Could not determine latest Stern version. Skipping."
		fi
	fi

	if command -v k9s >/dev/null 2>&1; then
		_info "k9s is already installed."
	else
		_info "Installing k9s..."
		local K9S_LATEST_URL
		K9S_LATEST_URL=$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d '"' -f 4)
		if [ -n "${K9S_LATEST_URL}" ]; then
			curl -Lo k9s.tar.gz "${K9S_LATEST_URL}"
			tar -xvf k9s.tar.gz k9s
			mv k9s /usr/local/bin/k9s
			rm k9s.tar.gz
			_info "k9s installed."
		else
			_warn "Could not determine latest k9s version. Skipping."
		fi
	fi
}

install_obsidian() {
	_info "Installing Obsidian..."
	local obsidian_url
	obsidian_url=$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)

	if [ -n "${obsidian_url}" ]; then
		_install_deb_package "obsidian" "${obsidian_url}"
	else
		_warn "Could not determine latest Obsidian .deb package. Skipping."
	fi
}

install_opencode() {
	_info "Installing opencode..."
	if command -v opencode >/dev/null 2>&1; then
		_info "opencode is already installed."
		return
	fi
	curl -fsSL https://opencode.ai/install | bash
}

install_slack() {
	local slack_version="4.38.125"
	local slack_url="https://downloads.slack-edge.com/releases/linux/${slack_version}/prod/x64/slack-desktop-${slack_version}-amd64.deb"
	_install_deb_package "slack" "${slack_url}"
}

install_spotify() {
	if command -v spotify >/dev/null 2>&1; then
		_info "Spotify is already installed."
		return
	fi
	_info "Installing Spotify..."
	curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
	echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list > /dev/null
	apt-get update
	apt-get install -y spotify-client
	_info "Spotify installed."
}

install_system_packages() {
	_info "Updating package lists..."
	apt-get update

	_info "Installing base packages..."
	apt-get install -y ${SYSTEM_PACKAGES}
}

link_dotfiles() {
	_info "Linking dotfiles..."
	files=".aliases .bash_profile .bashrc .gitconfig .tigrc .vimrc .zshrc"
	for file in $files; do
		if [ -f "${DOTFILES_DIR}/${file}" ]; then
			ln -sf "${DOTFILES_DIR}/${file}" "${HOME}/${file}"
			_info "Linked ${file}"
		else
			_warn "${DOTFILES_DIR}/${file} not found, skipping."
		fi
	done
}

setup_git() {
	_info "Configuring Git..."
	local name
	local email

	if ! git config --global user.name > /dev/null; then
		printf "Enter your full name for Git commits: "
		read -r name
		git config --global user.name "${name}"
	fi

	if ! git config --global user.email > /dev/null; then
		printf "Enter your email for Git commits: "
		read -r email
		git config --global user.email "${email}"
	fi
}

setup_ssh() {
	_info "Configuring SSH..."
	if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
		ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)" -f "${HOME}/.ssh/id_rsa" -N ""
		_info "New SSH key created."
	else
		_warn "SSH key already exists, skipping creation."
	fi

	_info "Your public SSH key is:"
	cat "${HOME}/.ssh/id_rsa.pub"
	
	if command -v xdg-open > /dev/null 2>&1; then
		xdg-open https://github.com/settings/keys
	fi

	printf "Please add the SSH key to your GitHub account and press [Enter] to continue..."
	read -r _
}

setup_vim() {
	_info "Setting up Vim with vim-plug..."
	if [ -f "${HOME}/.vim/autoload/plug.vim" ]; then
		_info "vim-plug is already installed."
	else
		curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	fi
	
	_info "Installing Vim plugins..."
	vim -u "${HOME}/.vimrc" +PlugInstall +qall
}

setup_zsh() {
	_info "Setting up Oh My Zsh and plugins..."
	if [ ! -d "${HOME}/.oh-my-zsh" ]; then
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	else
		_warn "Oh My Zsh already installed. Skipping."
	fi

	local ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
	git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" || true
	git clone --depth=1 https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM}/plugins/zsh-completions" || true
	git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" || true

	_info "Changing default shell to Zsh..."
	local zsh_path
	zsh_path=$(which zsh)
	if chsh -s "${zsh_path}" "$(logname)"; then
		_info "Default shell changed to ${zsh_path}."
		_info "Verifying..."
		local current_shell
		current_shell=$(getent passwd "$(logname)" | cut -d: -f7)
		if [ "${current_shell}" = "${zsh_path}" ]; then
			_info "Verification successful. Default shell is now ${zsh_path}."
		else
			_warn "Verification failed. The default shell is still ${current_shell}."
			_warn "You may need to log out and log back in for the change to be fully applied."
		fi
	else
		_warn "Failed to execute chsh command."
	fi
}

main() {
	check_root
	install_system_packages

	clone_dotfiles_repo
	link_dotfiles

	install_1password
	install_gh
	install_bitwarden
	install_docker
	install_k8s_tools
	install_opencode
	install_obsidian
	install_spotify
	install_slack

	setup_git
	setup_ssh
	setup_vim
	setup_zsh

	_info "✅ System setup complete!"
}

main "$@"
