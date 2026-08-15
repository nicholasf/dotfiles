CONFIG_DIR := $(HOME)/.config

.PHONY: to_local to_local_niri to_local_noctalia to_local_target from_local from_local_niri from_local_noctalia from_local_target diff

# Copy repo config OUT to ~/.config/<dir> (deploy)
to_local: to_local_niri to_local_noctalia

to_local_niri:
	@$(MAKE) to_local_target DIR=niri

to_local_noctalia:
	@$(MAKE) to_local_target DIR=noctalia

to_local_target:
	mkdir -p $(CONFIG_DIR)/$(DIR)
	cp -r $(DIR)/* $(CONFIG_DIR)/$(DIR)/
	@echo "Installed $(DIR) config to $(CONFIG_DIR)/$(DIR)"

# Copy live config IN from ~/.config/<dir> to repo (capture local changes for commit)
from_local: from_local_niri from_local_noctalia

from_local_niri:
	@$(MAKE) from_local_target DIR=niri

from_local_noctalia:
	@$(MAKE) from_local_target DIR=noctalia

FROM_LOCAL_EXCLUDES := --exclude=dms --exclude=README.md

from_local_target:
	rsync -a $(FROM_LOCAL_EXCLUDES) $(CONFIG_DIR)/$(DIR)/ $(DIR)/
	@echo "Pulled $(DIR) config from $(CONFIG_DIR)/$(DIR)"

diff:
	@diff -rq niri $(CONFIG_DIR)/niri || true
	@diff -rq noctalia $(CONFIG_DIR)/noctalia || true
