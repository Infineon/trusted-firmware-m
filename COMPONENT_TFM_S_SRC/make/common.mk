################################################################################
# \file common.mk
# \version 1.0
#
# \brief
# Trusted Firmware-M (TF-M) helper make file
#
################################################################################
# \copyright
# Copyright (c) 2022 Cypress Semiconductor Corporation (an Infineon company)
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

################################################################################
# Help macros
################################################################################

TFM_OS=$(shell uname)

ifneq (,$(findstring CYGWIN,$(TFM_OS)))

# Converts path to shell (Cygwin) path prefixed with /cygdrive/
TFM_PATH_SHELL=$(shell cygpath -u "$1")
# Converts path to cmake (Cygwin mixed) path prefixed with C:/abc/file.txt
TFM_PATH_MIXED=$(shell cygpath -m "$1")

else

# Keep path as is for other platforms (OS X, Linux)
TFM_PATH_SHELL=$1
TFM_PATH_MIXED=$1

endif

# Wraps space in target
space:=$(subst ,, )
TFM_WRAP_SPACE=$(subst $(space),\ ,$1)
TFM_UNWRAP_SPACE=$(subst \ ,$(space),$1)
# Wrape double quote
double_quote:=$(subst ,,")
TFM_WRAP_DOUBLE_QUOTE=$(subst $(double_quote),\",$1)

################################################################################
# Toolchain
################################################################################

ifeq ($(TOOLCHAIN),ARM)
# $1 output
TFM_DEPFLAGS = -MT $1 -MMD -MP -MF $1.d

# $1 - output
# $2 - input
# $3 - flags
TFM_PREPROCESSOR=$(CPP) --target=arm-arm-none-eabi -march=armv6-m $(call TFM_DEPFLAGS,$1) -P -xc $3 -c -o $1 $2
else ifeq ($(TOOLCHAIN),GCC_ARM)
# $1 output
TFM_DEPFLAGS = -MT $1 -MMD -MP -MF $1.d

# $1 - output
# $2 - input
# $3 - flags
TFM_PREPROCESSOR=$(CPP) $(call TFM_DEPFLAGS,$1) -P -xc $3 -o $1 $2
else ifeq ($(TOOLCHAIN),IAR)
# $1 output
TFM_DEPFLAGS = --dependencies=ms $1.d

# $1 - output
# $2 - input
# $3 - flags
TFM_PREPROCESSOR=$(CC) --preprocess=cns $1 $(call TFM_DEPFLAGS,$1) $3 -o $1 $2
else
$(error "TFM supports only GCC, ARMClang and IAR toolchains.")
endif
