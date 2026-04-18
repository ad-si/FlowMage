.PHONY: help
help: makefile
	@tail -n +4 makefile | grep ".PHONY"


.PHONY: format
format:
	uvx --from gdtoolkit==4.* gdformat --use-spaces=2 .
