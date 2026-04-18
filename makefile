.PHONY: help
help: makefile
	@tail -n +4 makefile | grep ".PHONY"


GDSCRIPT_PATHS := \
	*.gd \
	addons/flatcv/test_flatcv.gd

.PHONY: format
format:
	uvx --from gdtoolkit==4.* gdformat --use-spaces=2 $(GDSCRIPT_PATHS)


.PHONY: build-ext
build-ext:
	cd addons/flatcv && uvx --from scons scons -j$$(sysctl -n hw.ncpu 2>/dev/null || nproc)
