CONFIG_DIR := $(HOME)/.config

SYNC_DIRS := niri noctalia tmux

TO_LOCAL_TARGETS := $(addprefix to_local_,$(SYNC_DIRS))
FROM_LOCAL_TARGETS := $(addprefix from_local_,$(SYNC_DIRS))
DIFF_TARGETS := $(addprefix diff_,$(SYNC_DIRS))

.PHONY: to_local from_local diff tpm

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
