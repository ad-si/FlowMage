.PHONY: help
help: makefile
	@tail -n +4 makefile | grep ".PHONY"


GDSCRIPT_PATHS := \
	*.gd \
	GraphNodes/*.gd \
	tests/*.gd \
	addons/flatcv/test_flatcv.gd

.PHONY: format
format:
	uvx --from gdtoolkit==4.* gdformat --use-spaces=2 $(GDSCRIPT_PATHS)


.PHONY: build-ext
build-ext:
	cd addons/flatcv && uvx --from scons scons -j$$(sysctl -n hw.ncpu 2>/dev/null || nproc)


.PHONY: start
start:
	godot --path .


.PHONY: test
test:
	# Import first so the FlatCV GDExtension is registered before scripts load.
	godot --path . --headless --import
	godot --path . --headless --script tests/run_tests.gd
