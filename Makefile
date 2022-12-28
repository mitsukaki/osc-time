RM  = rm -f
CXX = g++

# colors make everything better
CYAN = \033[0;36m
RED  = \033[0;31m
NC   = \033[0m

# determine architecture
ifeq ($(shell uname -m), x86_64)
ARCH = 64
else
ARCH = 32
endif

# determine platform
"$(uname -s)" = "Linux"
ifeq ($(shell uname -s), "Linux")
PLATFORM = LINUX
LDLIBS = -lpthread -lm -ldl
else
PLATFORM = WINDOWS
EXEC_EXTENSION = .exe
LDLIBS = 
endif

SRCDIR = src
BINDIR = bin
CXXFLAGS = -Iinclude -Wall -Wextra -pedantic -std=c++11 -m$(ARCH) -w

EXEC = $(BINDIR)/osctime_x$(ARCH)$(EXEC_EXTENSION)
SRCS := $(shell find $(SRCDIR)/ -name *.cc)
OBJS := $(subst .cc,.o,$(SRCS))
OBJS := $(subst $(SRCDIR),$(BINDIR),$(OBJS))

all: $(EXEC)

release: clean .release

.release: CXXFLAGS += -O3
.release: $(EXEC)

$(EXEC): $(OBJS)
	$(CXX) -o $(EXEC) $(OBJS) -Llibs/ $(LDLIBS)

# implicit rule to compile source files in SRCDIR to object files in the BINDIR
$(BINDIR)/%.o: $(SRCDIR)/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

depend: .depend

.depend: $(SRCS)
	$(RM) ./.depend
	$(CXX) $(CXXFLAGS) -MM $^ | sed 's|[a-zA-Z0-9_-]*\.o|$(BINDIR)/&|' > ./.depend;

# call to check what your system is being detected as
about:
	@echo -e "$(CYAN)Compiling for $(ARCH) bit $(PLATFORM)$(NC)"

# call clean object files
clean:
	$(RM) $(shell find $(BINDIR)/ -name *.o)

# call to clean entirely & reset
reset: clean
	$(RM) *~ .depend
	$(RM) $(EXEC)

include .depend