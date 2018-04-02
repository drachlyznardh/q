
# Defining version numbers
MAJOR = 0
MINOR = 0
PATCH = 0
BUILD = 0

# Additional version qualifiers
COMMIT = $(shell git show-ref --head | grep HEAD | cut -b-40)

# Selecting build MODE: DEBUG/RELEASE
ifndef mode
mode=debug
endif

ifeq ($(mode), debug)
BUILDDIR = .debug/
VERSION  = $(MAJOR).$(MINOR).$(PATCH)-$(BUILD)-$(COMMIT)-DEBUG
else ifeq ($(mode), release)
BUILDDIR = .build/
VERSION  = $(MAJOR).$(MINOR).$(PATCH)-$(BUILD)-$(COMMIT)
else
$(error "Build mode is neither DEBUG nor RELEASE")
endif

NAME = q
TARGET = $(NAME)-v$(VERSION).bin

all: version
version:
	@echo "Building $(TARGET)"

help:
	@echo
	@echo "	Specify mode=debug/release"
	@echo
	@echo "		make version: show current target version"
	@echo
	@echo "		make clean         : clean current target version"
	@echo "		make debug-clean   : clean DEBUG target version"
	@echo "		make release-clean : clean RELEASE target version"
	@echo "		make very-clean    : clean both DEBUG/RELEASE target versions"
	@echo

clean:
	@echo -n "Cleaning ($(mode))… "
	@$(RM) $(BUILDDIR)
	@echo Done

debug-clean:
	@echo -n "Cleaning (DEBUG only)… "
	@$(RM) $(DEBUG_BUILDDIR)
	@echo Done

release-clean:
	@echo -n "Cleaning (RELEASE only) … "
	@$(RM) $(RELEASE_BUILDDIR)
	@echo Done

very-clean:
	@echo -n "Cleaning (both DEBUG/RELEASE) … "
	@$(RM) $(DEBUG_BUILDDIR) $(RELEASE_BUILDDIR)
	@echo Done

.PHONY: version help
.PHONY: clean debug-clean release-clean very-clean

