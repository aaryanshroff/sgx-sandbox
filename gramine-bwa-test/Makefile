# Build BWA as follows:
#
# - make               -- create non-SGX no-debug-log manifest
# - make SGX=1         -- create SGX no-debug-log manifest
# - make SGX=1 DEBUG=1 -- create SGX debug-log manifest
#
# Any of these invocations clones BWA's git repository and builds BWA in
# default configuration and in the latest-to-date (0.7.17) version.
#
# Use `make clean` to remove Gramine-generated files and `make distclean` to
# additionally remove the cloned BWA git repository.
#
# This Makefile is adapted from 
# https://github.com/gramineproject/gramine/blob/master/CI-Examples/redis/Makefile

################################# CONSTANTS ###################################

# directory with arch-specific libraries, used by BWA
# the below path works for Debian/Ubuntu; for CentOS/RHEL/Fedora, you should
# overwrite this default like this: `ARCH_LIBDIR=/lib64 make`
ARCH_LIBDIR ?= /lib/$(shell $(CC) -dumpmachine)

SRCDIR = src
BWA_VERSION = v0.7.17

ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
else
GRAMINE_LOG_LEVEL = error
endif

.PHONY: all
all: bwa bwa.manifest
ifeq ($(SGX),1)
all: bwa.manifest.sgx bwa.sig
endif

############################## BWA EXECUTABLE ###############################

# BWA is built as usual, without any changes to the build process. The source is 
# downloaded from the GitHub repo (6.0.5 tag) and built via `make`. The result 
# of this build process is the final executable "src/bwa".

$(SRCDIR)/Makefile:
	git clone --depth 1 --branch $(BWA_VERSION) https://github.com/lh3/bwa.git $(SRCDIR)
	sudo apt install zlib1g

$(SRCDIR)/src/bwa: $(SRCDIR)/Makefile
	make -C $(SRCDIR)

################################ BWA MANIFEST ###############################

# The template file is a Jinja2 template and contains almost all necessary
# information to run BWA under Gramine / Gramine-SGX. We create
# bwa.manifest (to be run under non-SGX Gramine) by replacing variables
# in the template file using the "gramine-manifest" script.

bwa.manifest: bwa.manifest.j2
	gramine-manifest \
		-Dlog_level=$(GRAMINE_LOG_LEVEL) \
		-Darch_libdir=$(ARCH_LIBDIR) \
		$< > $@

# Manifest for Gramine-SGX requires special "gramine-sgx-sign" procedure. This
# procedure measures all BWA trusted files, adds the measurement to the
# resulting manifest.sgx file (among other, less important SGX options) and
# creates bwa.sig (SIGSTRUCT object).

# gramine-sgx-sign generates both a .sig file and a .manifest.sgx file. This is somewhat
# hard to express properly in Make. The simple solution would be to use
# "Rules with Grouped Targets" (`&:`), however make on Ubuntu <= 20.04 doesn't support it.
#
# Simply using a normal rule with "two targets" is equivalent to creating separate rules
# for each of the targets, and when using `make -j`, this might cause two instances
# of gramine-sgx-sign to get launched simultaneously, potentially breaking the build.
#
# As a workaround, we use a dummy intermediate target, and mark both files as depending on it, to
# get the dependency graph we want. We mark this dummy target as .INTERMEDIATE, which means
# that make will consider the source tree up-to-date even if the sgx_sign file doesn't exist,
# as long as the other dependencies check out. This is in contrast to .PHONY, which would
# be rebuilt on every invocation of make.
bwa.sig bwa.manifest.sgx: sgx_outputs
	@:

.INTERMEDIATE: sgx_outputs
sgx_outputs: bwa.manifest $(SRCDIR)/src/bwa
	gramine-sgx-sign \
		--manifest bwa.manifest \
		--output bwa.manifest.sgx

########################### COPIES OF EXECUTABLES #############################

# BWA build process creates the final executable as src/bwa. For
# simplicity, copy it into our root directory.

bwa: $(SRCDIR)/bwa
	cp $< $@

############################## RUNNING BWA ##################################

ifeq ($(SGX),)
GRAMINE = gramine-direct
else
GRAMINE = gramine-sgx
endif

# Note that command-line arguments are hardcoded in the manifest file.
.PHONY: start
start: all
	$(GRAMINE) bwa

################################## CLEANUP ####################################

.PHONY: clean
clean:
	rm *.token *.sig *.manifest.sgx *.manifest bwa *.rdb

.PHONY: distclean
distclean:
	rm -r $(SRCDIR)