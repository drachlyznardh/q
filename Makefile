
# Defining version numbers
MAJOR = 0
MINOR = 0
PATCH = 0
BUILD = 0
CPPFLAGS+=$(foreach NAME,MAJOR MINOR PATCH BUILD,-DVERSION_$(NAME)=0x$($(NAME)))

# Additional version qualifiers
COMMIT = $(shell git show-ref --head | grep HEAD | cut -b-40)
CPPFLAGS+=-DVERSION_COMMIT='"$(COMMIT)"'

# Defining work directories
SRCDIR           =  src/
HDRDIR           =  hdr/
DEBUG_BUILDDIR   = .debug/
RELEASE_BUILDDIR = .build/

# Selecting build MODE: DEBUG/RELEASE
ifndef mode
mode = debug
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

CPPFLAGS += -DVERSION_NUMBER='"$(VERSION)"'

NAME   = q
TARGET = $(NAME)-v$(VERSION).bin

MAIN_NAMES = main

MAIN_OBJS = $(patsubst %,$(BUILDDIR)%.o,$(MAIN_NAMES))
MAIN_DEPS = $(MAIN_OBJS:.o=.d)

all: run

$(TARGET): $(MAIN_OBJS)

version:
	@echo "Building $(TARGET)"

show:
	@echo "SRCDIR=$(SRCDIR) HDRDIR=$(HDRDIR)"
	@echo "mode=$(mode)"
	@echo "VERSION=$(VERSION)"
	@echo "DEBUG_BUILDDIR=$(DEBUG_BUILDDIR) RELEASE_BUILDDIR=$(RELEASE_BUILDDIR) BUILDDIR=$(BUILDDIR)"
	@echo "MAIN_NAMES=$(MAIN_NAMES)"
	@echo "MAIN_OBJS=$(MAIN_OBJS)"
	@echo "MAIN_DEPS=$(MAIN_DEPS)"
	@echo "CPPFLAGS=$(CPPFLAGS)"
	@echo "CXXFLAGS=$(CXXFLAGS)"
	@echo "LDFLAGS=$(LDFLAGS)"

help:
	@echo
	@echo "	Specify mode=debug/release"
	@echo
	@echo "		make version       : show current target version"
	@echo "		make show          : display variable values"
	@echo
	@echo "		make target        : compile target application"
	@echo "		make test          : compile and execute test applications"
	@echo "		make run           : execute target application"
	@echo
	@echo "		make clean         : clean current target version"
	@echo "		make debug-clean   : clean DEBUG target version"
	@echo "		make release-clean : clean RELEASE target version"
	@echo "		make very-clean    : clean both DEBUG/RELEASE target versions"
	@echo
	@echo "		make self-test     : invoke various make targets"
	@echo

self-test: version show help

clean:
	@echo -n "Cleaning ($(mode))… "
	@$(RM) -R $(TARGET) $(BUILDDIR)
	@echo Done

debug-clean:
	@echo -n "Cleaning (DEBUG only)… "
	@$(RM) -R $(TARGET) $(DEBUG_BUILDDIR)
	@echo Done

release-clean:
	@echo -n "Cleaning (RELEASE only) … "
	@$(RM) -R $(TARGET) $(RELEASE_BUILDDIR)
	@echo Done

very-clean:
	@echo -n "Cleaning (both DEBUG/RELEASE) … "
	@$(RM) -R *.bin $(DEBUG_BUILDDIR) $(RELEASE_BUILDDIR)
	@echo Done

target: test $(TARGET)

test:

run: target
	@./$(TARGET)

$(TARGET):
	@echo -n "Linking target application $@ from $^ … "
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)
	@echo Done

$(BUILDDIR)%.o: $(SRCDIR)%.cpp
	@echo -n "Compiling object $@ from $< … "
	@mkdir -p $(dir $@)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $< -MMD -MT $@ -MF $(@:.o=.d)
	@echo Done

.PHONY: all version show help self-test
.PHONY: target test run
.PHONY: clean debug-clean release-clean very-clean

-include $(MAIN_DEPS)

