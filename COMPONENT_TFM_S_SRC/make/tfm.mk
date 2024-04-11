################################################################################
# \file tfm.mk
# \version 1.0
#
# \brief
# Trusted Firmware-M (TF-M) secure image make file
#
################################################################################
# \copyright
# Copyright (c) 2022-2024 Cypress Semiconductor Corporation (an Infineon company)
# or an affiliate of Cypress Semiconductor Corporation. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

# Directory with current makefile
TFM_MAKE_SRC_DIR:=$(realpath $(join $(dir $(lastword $(MAKEFILE_LIST))),..))

# Makefile with common macros
include $(join $(dir $(lastword $(MAKEFILE_LIST))),common.mk)

# delete target files on error
.DELETE_ON_ERROR:

################################################################################
# Settings - allows to configure build behaviour
################################################################################

TFM_GIT_URL?=https://github.com/Infineon/src-trusted-firmware-m.git
TFM_GIT_REF?=release-v1.3.120

TFM_PLATFORM?=cypress/psoc64
TFM_PROFILE?=profile_medium
TFM_ISOLATION_LEVEL?=2
TFM_CONFIGURE_OPTIONS?= -Wno-dev -DTFM_ISOLATION_LEVEL:STRING=$(TFM_ISOLATION_LEVEL) -DTFM_PLATFORM:STRING=$(TFM_PLATFORM) -DTFM_PROFILE:STRING=$(TFM_PROFILE)

ifneq ($(TFM_CMAKE_BUILD_TYPE),)
TFM_CONFIGURE_OPTIONS+= -DCMAKE_BUILD_TYPE=$(TFM_CMAKE_BUILD_TYPE)
else ifeq ($(CONFIG),Debug)
TFM_CONFIGURE_OPTIONS+= -DCMAKE_BUILD_TYPE=Debug
else ifeq ($(CONFIG),Release)
TFM_CONFIGURE_OPTIONS+= -DCMAKE_BUILD_TYPE=RelWithDebInfo
else
$(error Please use TFM_CMAKE_BUILD_TYPE (Debug, Release, RelWithDebInfo or MinSizeRel) or CONFIG (Debug, Release) to specify build type!)
endif

# Disable build of non-secure image by default
TFM_CONFIGURE_OPTIONS+= -DNS:BOOL=OFF

# Tell cmake to generate compile_commands.json
TFM_CONFIGURE_OPTIONS+= -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON

# Install CY MTB NS interface
TFM_CONFIGURE_OPTIONS+= -DCY_INSTALL_NS_INTERFACE:BOOL=ON

ifndef TFM_BUILD_DIR
TFM_BUILD_DIR:=$(call TFM_PATH_MIXED,$(_MTB_TOOLS__MAKEFILE_DIR)/build/$(TARGET)/$(CONFIG))
endif
TFM_TMP_DIR:=$(call TFM_PATH_MIXED,$(TFM_MAKE_SRC_DIR)/.tmp)
ifndef TFM_SRC_DIR
TFM_SRC_DIR:=$(call TFM_PATH_MIXED,$(TFM_TMP_DIR)/src)
endif
TFM_TOOLS_DIR:=$(call TFM_PATH_MIXED,$(TFM_TMP_DIR)/tools)
TFM_STAGES_DIR:=$(call TFM_PATH_MIXED,$(TFM_TMP_DIR)/stages)

ifeq ($(TOOLCHAIN),GCC_ARM)
# Setup GCC toolchain
TFM_TOOLCHAIN_FILE?=$(call TFM_PATH_MIXED,$(TFM_SRC_DIR)/toolchain_GNUARM.cmake)
else ifeq ($(TOOLCHAIN),ARM)
# Setup ARM toolchain
TFM_TOOLCHAIN_FILE?=$(call TFM_PATH_MIXED,$(TFM_SRC_DIR)/toolchain_ARMCLANG.cmake)
else ifeq ($(TOOLCHAIN),IAR)
# Setup IAR toolchain
TFM_TOOLCHAIN_FILE?=$(call TFM_PATH_MIXED,$(TFM_SRC_DIR)/toolchain_IARARM.cmake)
else
$(error "TF-M supports only GCC, ARMClang and IAR toolchains.")
endif

ifneq ($(CY_COMPILER_PATH),)
export TFM_TOOLCHAIN_PATH?=$(call TFM_PATH_SHELL,$(CY_COMPILER_PATH)/bin)
else ifneq ($(CY_CROSSPATH),)
export TFM_TOOLCHAIN_PATH?=$(call TFM_PATH_SHELL,$(CY_CROSSPATH)/bin)
endif

ifneq ($(TFM_TOOLCHAIN_PATH),)
SET_TFM_TOOLCHAIN_PATH=PATH="$(call TFM_PATH_SHELL,$(TFM_TOOLCHAIN_PATH)):$$PATH" &&
endif

TFM_CONFIGURE_OPTIONS+= "-DTFM_TOOLCHAIN_FILE:FILEPATH=$(TFM_TOOLCHAIN_FILE)"


ifndef TFM_COMPILE_COMMANDS_PATH
TFM_COMPILE_COMMANDS_PATH:=$(call TFM_PATH_MIXED,$(_MTB_TOOLS__MAKEFILE_DIR)/build/compile_commands.json)
endif
TFM_COMPILE_COMMANDS_SRC_PATH:=$(call TFM_PATH_MIXED,$(TFM_BUILD_DIR)/compile_commands.json)

################################################################################
# Libraries
################################################################################

#
# Setup library for TF-M
# $(1) - TF-M library CMake configuration variable name
# $(2) - user provided optional variable name which defines path to library
# $(3) - MTB library manager variable name which defines path to library
#
define TFM_SETUP_MTB_LIBRARY
ifneq ($($(2)),)
# Library location provided by user in application Makefile
TFM_CONFIGURE_OPTIONS+= "-D$(1):STRING=$($(2))"
else ifneq ($($(3)),)
# Use library defined by MTB Library Manager
TFM_CONFIGURE_OPTIONS+= "-D$(1):STRING=$(call TFM_PATH_MIXED,$(_MTB_TOOLS__MAKEFILE_DIR)/$($(3)))"
else
# Use library provided by TF-M
endif
endef

# === psoc6pdl ===
# Use TFM_LIB_PDL to specify custom psoc6pdl library location
$(eval $(call TFM_SETUP_MTB_LIBRARY,CY_PSOC6PDL_LIB_PATH,TFM_LIB_PDL,SEARCH_mtb-pdl-cat1))

# === p64_utils ===
# Use TFM_LIB_P64_UTILS to specify custom p64_utils library location
$(eval $(call TFM_SETUP_MTB_LIBRARY,CY_P64_UTILS_LIB_PATH,TFM_LIB_P64_UTILS,SEARCH_p64_utils))

# === core-lib ===
# Use TFM_LIB_CY_CORE_LIB to specify custom core-lib library location
$(eval $(call TFM_SETUP_MTB_LIBRARY,CY_CORE_LIB_PATH,TFM_LIB_CY_CORE_LIB,SEARCH_core-lib))

# === mbedtls ===
# Use TFM_LIB_MBEDTLS to specify custom mbedtls library location
$(eval $(call TFM_SETUP_MTB_LIBRARY,MBEDCRYPTO_PATH,TFM_LIB_MBEDTLS,SEARCH_mbedtls))

# === cy-mbedtls-acceleration ===
# Use TFM_LIB_CY_MBEDTLS_ACCELERATION to specify custom cy-mbedtls-acceleration library location
$(eval $(call TFM_SETUP_MTB_LIBRARY,CY_MBEDTLS_ACCELERATION_PATH,TFM_LIB_CY_MBEDTLS_ACCELERATION,SEARCH_cy-mbedtls-acceleration))

TFM_CONFIGURE_OPTIONS+= $(TFM_CONFIGURE_EXT_OPTIONS)

################################################################################
# Tools location
################################################################################

# Try to use system cmake instead of installing
TFM_TOOLS_CMAKE?=$(shell which cmake 2>/dev/null)

################################################################################
# Local variables
################################################################################

# Is used to unzip archives (e.g. CMake archive)
TFM_PY_UNZIP="exec(\"import sys\nfrom zipfile import PyZipFile\nfor zip_file in sys.argv[1:]:\n    pzf = PyZipFile(zip_file)\n    pzf.extractall()\")"

ifeq ($(TFM_TOOLS_CMAKE),)
# Prepare variables to install CMake
TFM_TOOLS_CMAKE_INSTALL=true

ifneq (,$(findstring CYGWIN,$(TFM_OS)))
# ModusToolbox on Windows (with cygwin)
TFM_TOOLS_CMAKE_WIN_URL?=https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2-windows-i386.zip
TFM_TOOLS_CMAKE_WIN_PATH?=cmake-3.22.2-windows-i386/bin/cmake.exe
TFM_TOOLS_CMAKE_WIN_INSTALL=$(CY_PYTHON_PATH) -c $(TFM_PY_UNZIP) "$(call TFM_PATH_MIXED,$<)"

TFM_TOOLS_CMAKE_URL=$(TFM_TOOLS_CMAKE_WIN_URL)
TFM_TOOLS_CMAKE_INSTALL_CMD=$(TFM_TOOLS_CMAKE_WIN_INSTALL)
TFM_TOOLS_CMAKE:=$(call TFM_PATH_MIXED,$(TFM_TOOLS_DIR)/$(TFM_TOOLS_CMAKE_WIN_PATH))

else ifneq (,$(findstring Darwin,$(TFM_OS)))
# ModusToolbox on OS X
TFM_TOOLS_CMAKE_OSX_URL?=https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2-macos-universal.tar.gz
TFM_TOOLS_CMAKE_OSX_PATH?=cmake-3.22.2-macos-universal/CMake.app/Contents/bin/cmake
TFM_TOOLS_CMAKE_OSX_INSTALL=tar -zxf "$<"

TFM_TOOLS_CMAKE_URL=$(TFM_TOOLS_CMAKE_OSX_URL)
TFM_TOOLS_CMAKE_INSTALL_CMD=$(TFM_TOOLS_CMAKE_OSX_INSTALL)
TFM_TOOLS_CMAKE:=$(call TFM_PATH_MIXED,$(TFM_TOOLS_DIR)/$(TFM_TOOLS_CMAKE_OSX_PATH))

else ifneq (,$(findstring Linux,$(TFM_OS)))
# ModusToolbox on Linux
TFM_TOOLS_CMAKE_LINUX_URL?=https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2-linux-x86_64.tar.gz
TFM_TOOLS_CMAKE_LINUX_PATH?=cmake-3.22.2-linux-x86_64/bin/cmake
TFM_TOOLS_CMAKE_LINUX_INSTALL=tar -zxf "$<"

TFM_TOOLS_CMAKE_URL=$(TFM_TOOLS_CMAKE_LINUX_URL)
TFM_TOOLS_CMAKE_INSTALL_CMD=$(TFM_TOOLS_CMAKE_LINUX_INSTALL)
TFM_TOOLS_CMAKE:=$(call TFM_PATH_MIXED,$(TFM_TOOLS_DIR)/$(TFM_TOOLS_CMAKE_LINUX_PATH))

else
$(error "TF-M build system supports only Windows, Linux and OS X.")
endif
TFM_TOOLS_CMAKE_ARCHIVE=$(call TFM_PATH_MIXED,$(TFM_TMP_DIR)/downloads/$(shell basename "$(TFM_TOOLS_CMAKE_URL)"))
endif

TFM_TOOLS_WGET?=$(shell which wget 2>/dev/null)
ifneq ($(TFM_TOOLS_WGET),)
TFM_TOOLS_DOWNLOAD_CMD=$(TFM_TOOLS_WGET) -O "$1" $2
else
TFM_TOOLS_CURL?=$(shell which curl 2>/dev/null)
ifneq ($(TFM_TOOLS_CURL),)
TFM_TOOLS_DOWNLOAD_CMD=$(TFM_TOOLS_CURL) -o "$1" -L $2
else
$(error No wget or curl found, please install one of these tools or provide path to one and repeat make getlibs)
endif
endif


################################################################################
# Targets
################################################################################

# Create dirs
$(TFM_TMP_DIR):
	@mkdir -pv $(TFM_TMP_DIR)

$(TFM_TMP_DIR)/downloads:
	mkdir -p $(TFM_TMP_DIR)/downloads

$(TFM_SRC_DIR):
	@mkdir -pv $(TFM_SRC_DIR)

$(TFM_TOOLS_DIR):
	@mkdir -pv $(TFM_TOOLS_DIR)

$(TFM_STAGES_DIR):
	@mkdir -pv $(TFM_STAGES_DIR)

# Checkout TF-M sources
.PHONY: tfm-src
tfm-src $(TFM_STAGES_DIR)/src: | $(TFM_SRC_DIR) $(TFM_STAGES_DIR)
	@echo "=============================================================================="
	@echo "Checking out TF-M ..."
	@echo "=============================================================================="
	cd $(TFM_SRC_DIR) && \
	git init . && \
	git config --local core.autocrlf false && \
	git config --local core.eol lf && \
	git remote rm origin 2>/dev/null; \
	git remote add origin $(TFM_GIT_URL) && \
	git fetch origin $(TFM_GIT_REF) && \
	git reset --hard FETCH_HEAD && \
	touch "$(TFM_STAGES_DIR)/src"

ifneq ($(TFM_BUILD_DIR),)
$(TFM_BUILD_DIR):
	@mkdir -pv $(TFM_BUILD_DIR)

# Configure TF-M
.PHONY: tfm-configure
tfm-configure $(TFM_BUILD_DIR)/.tfm-configure: $(TFM_STAGES_DIR)/src $(TFM_STAGES_DIR)/tools-pyreq | $(call TFM_WRAP_SPACE,$(TFM_TOOLS_CMAKE)) $(TFM_BUILD_DIR)
	@echo "=============================================================================="
	@echo "Configuring TF-M ..."
	@echo "=============================================================================="
	@mkdir -pv $(TFM_BUILD_DIR)/.tmp
	. $(TFM_TOOLS_ACTIVATE_PYENV) && \
	$(SET_TFM_TOOLCHAIN_PATH) \
	"$(TFM_TOOLS_CMAKE)" $(TFM_CONFIGURE_OPTIONS) -G "Unix Makefiles" -S "$(call TFM_PATH_MIXED,${TFM_SRC_DIR})" -B $(TFM_BUILD_DIR) && \
	echo "LAST_TFM_CONFIGURE_OPTIONS=$(call TFM_WRAP_DOUBLE_QUOTE,$(TFM_CONFIGURE_OPTIONS))" >"$(TFM_BUILD_DIR)/.tfm-configure.mk" && \
	install $(TFM_COMPILE_COMMANDS_SRC_PATH) $(TFM_COMPILE_COMMANDS_PATH) && \
	touch "$(TFM_BUILD_DIR)/.tfm-configure"

# Build TF-M
.PHONY: tfm-make
# Validate configuration flags
-include $(TFM_BUILD_DIR)/.tfm-configure.mk
ifneq ($(LAST_TFM_CONFIGURE_OPTIONS),$(TFM_CONFIGURE_OPTIONS))
# There are changes in configuration flags, force configuration with new settings
tfm-make $(TFM_BUILD_DIR)/.tfm-make: tfm-configure
else
# There are no changes in configuration flags, reconfigure only if $(TFM_BUILD_DIR)/.tfm-configure is missed
tfm-make $(TFM_BUILD_DIR)/.tfm-make: $(TFM_BUILD_DIR)/.tfm-configure | $(TFM_BUILD_DIR)
endif
	@echo "=============================================================================="
	@echo "Building TF-M SPE ..."
	@echo "=============================================================================="
	. $(TFM_TOOLS_ACTIVATE_PYENV) && \
	cd $(TFM_BUILD_DIR) && \
	$(SET_TFM_TOOLCHAIN_PATH) \
	$(MAKE) install && \
	install $(TFM_COMPILE_COMMANDS_SRC_PATH) $(TFM_COMPILE_COMMANDS_PATH); \
	touch "$(TFM_BUILD_DIR)/.tfm-make"

.PHONY: tfm-build
tfm-build: tfm-make
	@echo "=============================================================================="
	@echo "Building TF-M SPE ... Done"
	@echo "=============================================================================="

endif   # ifneq ($(TFM_BUILD_DIR),)

################################################################################
# Tools
################################################################################

# === Prepare CMake ===
ifneq ($(TFM_TOOLS_CMAKE_INSTALL),)
# Install CMake
$(TFM_TOOLS_CMAKE_ARCHIVE): | $(TFM_TMP_DIR)/downloads
	@echo "=============================================================================="
	@echo "Downloading CMake ..."
	@echo "=============================================================================="
	$(call TFM_TOOLS_DOWNLOAD_CMD,$(TFM_TOOLS_CMAKE_ARCHIVE),$(TFM_TOOLS_CMAKE_URL))

$(TFM_TOOLS_CMAKE): $(TFM_TOOLS_CMAKE_ARCHIVE) | $(TFM_TOOLS_DIR) $(TFM_STAGES_DIR)
	@echo "=============================================================================="
	@echo "Unpacking CMake ..."
	@echo "=============================================================================="
	cd $(TFM_TOOLS_DIR) && \
	$(TFM_TOOLS_CMAKE_INSTALL_CMD) && \
	touch $(TFM_TOOLS_CMAKE) \
	|| (rm -f $(TFM_TOOLS_CMAKE_ARCHIVE); false)

.PHONY: tfm-tools-cmake
tfm-tools-cmake: $(TFM_TOOLS_CMAKE)
else
# Use system provided CMake
.PHONY: tfm-tools-cmake
tfm-tools-cmake:
	@echo "Use cmake : $(TFM_TOOLS_CMAKE)"
endif


# === Python requirements within pyenv ===
ifneq (,$(findstring CYGWIN,$(TFM_OS)))
TFM_TOOLS_ACTIVATE_PYENV=$(TFM_TOOLS_DIR)/tfm-pyenv/Scripts/activate
# Convert Windows line endings to Unix
TFM_PREPARE_PYENV=dos2unix $(TFM_TOOLS_ACTIVATE_PYENV) &&
else
TFM_TOOLS_ACTIVATE_PYENV=$(TFM_TOOLS_DIR)/tfm-pyenv/bin/activate
endif

$(TFM_STAGES_DIR)/tools-pyenv: | $(TFM_TOOLS_DIR) $(TFM_STAGES_DIR)
	@echo "=============================================================================="
	@echo "Creating pyenv for TF-M prerequisites"
	@echo "=============================================================================="
	rm -rf "$(call TFM_PATH_MIXED,$(TFM_TOOLS_DIR)/tfm-pyenv)" && \
	$(CY_PYTHON_PATH) -m venv "$(call TFM_PATH_MIXED,$(TFM_TOOLS_DIR)/tfm-pyenv)" && \
	$(TFM_PREPARE_PYENV) \
	touch "$@"

$(TFM_STAGES_DIR)/tools-pyreq: $(TFM_STAGES_DIR)/src $(TFM_STAGES_DIR)/tools-pyenv | $(TFM_TOOLS_DIR) $(TFM_STAGES_DIR)
	@echo "=============================================================================="
	@echo "Installing TF-M Python prerequisites"
	@echo "=============================================================================="
# Skip installation of requirements.txt
# There are lot of tools which are used for documentation only
#	pip install -r "$(call TFM_PATH_MIXED,$(TFM_SRC_DIR)/tools/requirements.txt)"
	. $(TFM_TOOLS_ACTIVATE_PYENV) && \
	pip install --disable-pip-version-check Jinja2 PyYAML cbor\>=1.0.0 && \
	touch "$@"

.PHONY: tfm-tools-pyenv
tfm-tools-pyenv: $(TFM_STAGES_DIR)/tools-pyenv $(TFM_STAGES_DIR)/tools-pyreq

# === Tools ===
.PHONY: tfm-tools
tfm-tools: tfm-tools-cmake tfm-tools-pyenv
	@echo "TF-M Tools installed"


################################################################################
# getlibs
################################################################################

tfm-download: tfm-src tfm-tools
