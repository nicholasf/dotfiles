CONFIG_DIR := $(HOME)/.config/niri

.PHONY: install pull diff

# Copy repo config OUT to ~/.config/niri (deploy)
install:
	mkdir -p $(CONFIG_DIR)
	cp -r niri/* $(CONFIG_DIR)/
	@echo "Installed niri config to $(CONFIG_DIR)"

pull:
	cp -r $(CONFIG_DIR)/* niri/
	@echo "Pulled live niri config into repo — review with 'git diff' before committing"

# Show what differs between repo and live config
diff:
	@diff -rq niri $(CONFIG_DIR) || true