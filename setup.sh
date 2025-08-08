#!/bin/bash
# A script to set up a new Ubuntu system.
# To run: sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup.sh)"

DOTFILES_REPO="https://github.com/ryanschuhler/system-setup.git"
DOTFILES_DIR="${HOME}/repos/system-setup"
SYSTEM_PACKAGES="
	build-essential
	ca-certificates
	curl
	git
	htop
	jq
	nodejs
	openvpn
	tig
	tree
	unzip
	vim
	wget
	zsh"

_info() {
	echo -e "\033[1;34m[INFO]\033[0m ${1}"
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

install_system_packages() {
	_info "Updating package lists..."
	apt-get update

	_info "Installing base packages..."
	apt-get install -y ${SYSTEM_PACKAGES}
}

install_1password() {
	_info "Installing 1Password..."
	curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | tee /etc/apt/sources.list.d/1password.list > /dev/null

	apt-get update
	apt-get install -y 1password
	_info "1Password installed."
}

install_bitwarden() {
	_info "Installing Bitwarden via .deb package..."
	local bitwarden_deb="bitwarden.deb"
	curl -L "https://vault.bitwarden.com/download/?app=desktop&platform=linux&type=deb" -o "${bitwarden_deb}"
	
	apt-get install -y ./"${bitwarden_deb}"
	rm "${bitwarden_deb}"
	_info "Bitwarden installed."
}

install_slack() {
	_info "Installing Slack via .deb package..."
	local slack_deb="slack-desktop.deb"

	curl -L "https://slack.com/get/linux/deb" -o "${slack_deb}"

	apt-get install -y ./"${slack_deb}"
	rm "${slack_deb}"
	_info "Slack installed."
}

install_docker() {
	_info "Installing Docker using the convenience script..."
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
	rm get-docker.sh
	_info "Docker installed."

	_info "Configuring Docker to run without sudo..."
	groupadd --force docker
	usermod -aG docker "$(logname)"
	_info "User '$(logname)' added to the docker group. You will need to log out and back in for this to take effect."
}

setup_git_and_ssh() {
	_info "Configuring Git and SSH..."
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

	if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
		ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)" -f "${HOME}/.ssh/id_rsa" -N ""
		_info "New SSH key created."
	else
		_warn "SSH key already exists, skipping creation."
	fi

	_info "Your public SSH key is:"
	cat "${HOME}/.ssh/id_rsa.pub"
	
	if command -v xdg-open &> /dev/null; then
		xdg-open https://github.com/settings/keys
	fi

	printf "Please add the SSH key to your GitHub account and press [Enter] to continue..."
	read -r _
}

clone_dotfiles_repo() {
	_info "Cloning dotfiles repository..."
	if [ -d "${DOTFILES_DIR}" ]; then
		_warn "Dotfiles directory already exists. Skipping clone."
	else
		git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"
	fi
}

link_dotfiles() {
	_info "Linking dotfiles..."
	local files=(".aliases" ".bash_profile" ".bashrc" ".gitconfig" ".tigrc" ".vimrc" ".zshrc")
	for file in "${files[@]}"; do
		if [ -f "${DOTFILES_DIR}/${file}" ]; then
			ln -sf "${DOTFILES_DIR}/${file}" "${HOME}/${file}"
			_info "Linked ${file}"
		else
			_warn "${DOTFILES_DIR}/${file} not found, skipping."
		fi
	done
}

setup_vim() {
	_info "Setting up Vim with vim-plug..."
	curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	
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
	chsh -s "$(which zsh)" "$(logname)"
}

install_k8s_tools() {
	_info "Installing Kubernetes tools (k3s, Helm, Stern)..."
	
	curl -sfL https://get.k3s.io | sh -
	_info "k3s master installed. Find the node token at /var/lib/rancher/k3s/server/node-token"

	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

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
}

main() {
	check_root
	install_system_packages
	install_1password
	install_bitwarden
	install_slack
	install_docker
	setup_git_and_ssh
	clone_dotfiles_repo
	link_dotfiles
	setup_vim
	setup_zsh
	install_k8s_tools

	_info "✅ System setup complete!"
	_info "Please log out and log back in for all changes to take effect, especially the new Zsh shell."
}

main "$@"