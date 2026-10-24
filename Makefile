CONFIG_DIR := $(HOME)/.config

SYNC_DIRS := niri noctalia tmux

TO_LOCAL_TARGETS := $(addprefix to_local_,$(SYNC_DIRS))
FROM_LOCAL_TARGETS := $(addprefix from_local_,$(SYNC_DIRS))
DIFF_TARGETS := $(addprefix diff_,$(SYNC_DIRS))

.PHONY: to_local from_local diff tpm deps_fedora setup_fedora deps_ubuntu setup_ubuntu neovim_fedora neovim_ubuntu lazyvim

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

# Base packages (Fedora). Noctalia/Quickshell is not installed here.
DEPS := git rsync tmux niri

deps_fedora:
	sudo dnf install -y $(DEPS)

# Bootstrap a new machine: packages, configs, then tpm
setup_fedora: deps_fedora neovim_fedora lazyvim to_local tpm
	@echo "Setup complete. Start tmux and press prefix + I to install plugins."

# Ubuntu equivalents. niri and Noctalia/Quickshell are not installed here.
DEPS_UBUNTU := git rsync tmux

deps_ubuntu:
	sudo apt-get update
	sudo apt-get install -y $(DEPS_UBUNTU)

setup_ubuntu: deps_ubuntu neovim_ubuntu lazyvim to_local tpm
	@echo "Setup complete. Start tmux and press prefix + I to install plugins."

# Neovim
neovim_fedora:
	sudo dnf install -y neovim

# Needs a release whose apt neovim is new enough for LazyVim (check: apt-cache policy neovim)
neovim_ubuntu:
	sudo apt-get install -y neovim

# LazyVim starter (distro-independent). Skips if ~/.config/nvim exists; run nvim once to bootstrap plugins.
lazyvim:
	@if [ -e $(CONFIG_DIR)/nvim ]; then \
		echo "$(CONFIG_DIR)/nvim already exists, skipping LazyVim starter"; \
	else \
		git clone https://github.com/LazyVim/starter $(CONFIG_DIR)/nvim && rm -rf $(CONFIG_DIR)/nvim/.git; \
	fi
