CONFIG_DIR := $(HOME)/.config

.PHONY: sync sync_niri sync_noctalia sync_target pull diff

# Copy repo config OUT to ~/.config/<dir> (deploy)
sync: sync_niri sync_noctalia

sync_niri:
	@$(MAKE) sync_target DIR=niri

sync_noctalia:
	@$(MAKE) sync_target DIR=noctalia

sync_target:
	mkdir -p $(CONFIG_DIR)/$(DIR)
	cp -r $(DIR)/* $(CONFIG_DIR)/$(DIR)/
	@echo "Installed $(DIR) config to $(CONFIG_DIR)/$(DIR)"

diff:
	@diff -rq niri $(CONFIG_DIR)/niri || true
	@diff -rq noctalia $(CONFIG_DIR)/noctalia || true