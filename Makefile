NAME=dvm
VERSION=0.9.0
AUTHOR=fnichol
URL=https://github.com/$(AUTHOR)/$(NAME)

DIRS=etc lib bin sbin share
INSTALL_DIRS=`find $(DIRS) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f 2>/dev/null`
DOC_FILES=*.md *.txt
DATA_FILES=Vagrantfile README.*
CONF_FILES=dvm.conf

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
SIG=$(PKG).asc

PREFIX?=/usr/local
DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)
DATA_DIR?=$(HOME)/.dvm

pkg:
	mkdir $(PKG_DIR)

download: pkg
	wget -O $(PKG) $(URL)/archive/v$(VERSION).tar.gz

build: pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

sign: $(PKG)
	gpg --sign --detach-sign --armor $(PKG)
	git add $(PKG).asc
	git commit $(PKG).asc -m "Added PGP signature for v$(VERSION)"
	git push origin master

verify: $(PKG) $(SIG)
	gpg --verify $(SIG) $(PKG)

clean:
	rm -f $(PKG) $(SIG)

all: $(PKG) $(SIG)

tag:
	git push origin master
	git tag -s -m "Releasing $(VERSION)" v$(VERSION)
	git push origin master --tags

release: tag download sign

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(PREFIX)/$$file; done
	mkdir -p $(DOC_DIR)
	cp -r $(DOC_FILES) $(DOC_DIR)/
	mkdir -p $(DATA_DIR)
	for file in $(DATA_FILES); do cp $$file $(DATA_DIR)/$$file; done
	for file in $(CONF_FILES); do if [ ! -f $(DATA_DIR)/$$file ]; then cp $$file $(DATA_DIR)/$$file; fi; done

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(PREFIX)/$$file; done
	rm -rf $(DOC_DIR)

.PHONY: build download sign verify clean tag release install uninstall all
