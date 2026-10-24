CONFIG_DIR := $(HOME)/.config

SYNC_DIRS := niri noctalia tmux

TO_LOCAL_TARGETS := $(addprefix to_local_,$(SYNC_DIRS))
FROM_LOCAL_TARGETS := $(addprefix from_local_,$(SYNC_DIRS))
DIFF_TARGETS := $(addprefix diff_,$(SYNC_DIRS))

.PHONY: to_local from_local diff tpm deps_fedora setup_fedora deps_ubuntu setup_ubuntu neovim_fedora neovim_ubuntu lazyvim noctalia_fedora niri_ubuntu noctalia_ubuntu

# Copy repo config OUT to ~/.config/<dir> (deploy)
to_local: $(TO_LOCAL_TARGETS)

to_local_%:
	mkdir -p $(CONFIG_DIR)/$*
	cp -r $*/* $(CONFIG_DIR)/$*/
	@echo "Installed $* config to $(CONFIG_DIR)/$*"

# Copy live config IN from ~/.config/<dir> to repo (capture local changes for commit)
from_local: $(FROM_LOCAL_TARGETS)

FROM_LOCAL_EXCLUDES := --exclude=dms --exclude=README.md --exclude=plugins

from_local_%:
	rsync -a $(FROM_LOCAL_EXCLUDES) $(CONFIG_DIR)/$*/ $*/
	@echo "Pulled $* config from $(CONFIG_DIR)/$*"

diff: $(DIFF_TARGETS)

diff_%:
	@diff -rq $* $(CONFIG_DIR)/$* || true

# Install tmux plugin manager (idempotent); then press prefix + I in tmux to fetch plugins
TPM_DIR := $(CONFIG_DIR)/tmux/plugins/tpm

tpm:
	@if [ -d $(TPM_DIR) ]; then \
		echo "tpm already installed at $(TPM_DIR)"; \
	else \
		git clone https://github.com/tmux-plugins/tpm $(TPM_DIR); \
	fi

# Base packages (Fedora)
DEPS := git rsync tmux niri

deps_fedora:
	sudo dnf install -y $(DEPS)

# Bootstrap a new machine: packages, configs, then tpm
setup_fedora: deps_fedora noctalia_fedora neovim_fedora lazyvim to_local tpm
	@echo "Setup complete. Start tmux and press prefix + I to install plugins."

# Ubuntu 24.04 (noble) equivalents
DEPS_UBUNTU := git rsync tmux curl software-properties-common build-essential

deps_ubuntu:
	sudo apt-get update
	sudo apt-get install -y $(DEPS_UBUNTU)

setup_ubuntu: deps_ubuntu niri_ubuntu noctalia_ubuntu neovim_ubuntu lazyvim to_local tpm
	@echo "Setup complete. Start tmux and press prefix + I to install plugins."

# Neovim
neovim_fedora:
	sudo dnf install -y neovim

# Ubuntu 24.04's own neovim (0.9.x) is too old for LazyVim, so use the neovim PPA
neovim_ubuntu:
	sudo add-apt-repository -y ppa:neovim-ppa/unstable
	sudo apt-get update
	sudo apt-get install -y neovim

# LazyVim starter (distro-independent). Skips if ~/.config/nvim exists; run nvim once to bootstrap plugins.
lazyvim:
	@if [ -e $(CONFIG_DIR)/nvim ]; then \
		echo "$(CONFIG_DIR)/nvim already exists, skipping LazyVim starter"; \
	else \
		git clone https://github.com/LazyVim/starter $(CONFIG_DIR)/nvim && rm -rf $(CONFIG_DIR)/nvim/.git; \
	fi

# Noctalia v5. In Fedora's repos from 44; before that use the LionHeartP Copr (git snapshots).
noctalia_fedora:
	@. /etc/os-release; \
	if [ "$$VERSION_ID" -ge 44 ]; then \
		sudo dnf install -y noctalia; \
	else \
		sudo dnf install -y 'dnf-command(copr)' && sudo dnf copr enable -y lionheartp/Hyprland && sudo dnf install -y noctalia-git; \
	fi

# Ubuntu 24.04 has no niri package, so build it from source with rustup's cargo
NIRI_BUILD_DEPS := gcc clang libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev libwayland-dev \
	libinput-dev libdbus-1-dev libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev

niri_ubuntu:
	sudo apt-get install -y $(NIRI_BUILD_DEPS)
	@command -v cargo >/dev/null 2>&1 || [ -x $(HOME)/.cargo/bin/cargo ] || \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	@set -e; dir=$$(mktemp -d); \
	git clone --depth 1 https://github.com/YaLTeR/niri $$dir/niri; \
	cd $$dir/niri; \
	PATH="$(HOME)/.cargo/bin:$$PATH" cargo build --release; \
	sudo install -Dm755 target/release/niri /usr/local/bin/niri; \
	sudo install -Dm755 resources/niri-session /usr/local/bin/niri-session; \
	sudo install -Dm644 resources/niri.desktop /usr/local/share/wayland-sessions/niri.desktop; \
	sudo install -Dm644 resources/niri-portals.conf /usr/local/share/xdg-desktop-portal/niri-portals.conf; \
	sudo install -Dm644 resources/niri.service /etc/systemd/user/niri.service; \
	sudo install -Dm644 resources/niri-shutdown.target /etc/systemd/user/niri-shutdown.target; \
	sudo sed -i 's|/usr/bin/|/usr/local/bin/|' /usr/local/bin/niri-session /etc/systemd/user/niri.service; \
	rm -rf $$dir

# Noctalia v5 has no apt package for 24.04 (upstream's repo starts at 26.04), so build from source
NOCTALIA_BUILD_DEPS := just meson libwayland-dev wayland-protocols libfreetype-dev libfontconfig-dev \
	libcairo2-dev libpango1.0-dev librsvg2-dev libxkbcommon-dev libepoxy-dev libgles-dev libwebp-dev \
	libcurl4-gnutls-dev libmd4c-dev nlohmann-json3-dev libsdbus-c++-dev libsecret-1-dev libsodium-dev \
	libstb-dev libtomlplusplus-dev libpipewire-0.3-dev libpam0g-dev libpolkit-agent-1-dev \
	libpolkit-gobject-1-dev libqalculate-dev libwireplumber-0.5-dev libxml2-dev libjemalloc-dev

noctalia_ubuntu:
	sudo apt-get install -y $(NOCTALIA_BUILD_DEPS)
	@set -e; dir=$$(mktemp -d); \
	git clone --depth 1 --branch main https://github.com/noctalia-dev/noctalia $$dir/noctalia; \
	cd $$dir/noctalia; \
	just configure release; \
	just build release; \
	sudo just install release; \
	rm -rf $$dir
