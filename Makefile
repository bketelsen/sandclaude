PREFIX = $(HOME)/.local/bin
SCRIPT = sandclaude

.PHONY: install uninstall

install:
	mkdir -p $(PREFIX)
	ln -sf $(CURDIR)/$(SCRIPT) $(PREFIX)/$(SCRIPT)

uninstall:
	rm -f $(PREFIX)/$(SCRIPT)
