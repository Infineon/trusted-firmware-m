# Cypress Trusted Firmware-M (TF-M) for PSoC64

## Overview

Trusted Firmware-M is free software that provides secure world software for Arm Cortex-M processors. It forms the foundations
of the Secure Processing Environment (SPE) of microcontrollers. To work with Cypress devices, Cypress has modified TF-M to support PSoC 64 devices.

This software component is licensed under a mixture of the Apache License, version 2 and the 3-Clause BSD License. Please see the individual files to determine which license applies. Source files can be found in Trusted Firmware-M [GIT](https://git.trustedfirmware.org/trusted-firmware-m.git). Specifically, take note of the following modules.
* [t_cose](https://git.trustedfirmware.org/TF-M/trusted-firmware-m.git/tree/lib/ext/t_cose/LICENSE)
* [qcbor](https://git.trustedfirmware.org/TF-M/trusted-firmware-m.git/tree/lib/ext/qcbor/README.md)


## Requirements

* [ModusToolbox® software](https://www.cypress.com/products/modustoolbox-software-environment) v2.3
* Board Support Package (BSP) minimum required version: 3.0.0
* PDL version: 2.3.0
* Programming Language: C
* Associated Parts: See "Supported Kits" section below.

## Supported Toolchains

* GNU Arm® Embedded Compiler v9.3.1
* Arm compiler v6.13
* IAR C/C++ compiler v8.42.1

## Supported Kits

* [PSoC® 64 Standard Secure - AWS Wi-Fi BT Pioneer Kit (CY8CKIT-064S0S2-4343W)](https://www.cypress.com/documentation/development-kitsboards/psoc-64-standard-secure-aws-wi-fi-bt-pioneer-kit-cy8ckit)

## Features

The current implementation supports the following services:
* PSA Crypto
* PSA Initial Attestation
* PSA Internal Trusted Storage
* PSA Protected Storage
These services are defined by the [PSA API](https://github.com/ARM-software/psa-arch-tests/tree/master/api-specs)

## Quick Start

### Provisioning the kit
Refer to the [Provisioning Guide](https://www.cypress.com/file/521106/download)

### Adding the library

You can add a dependency file (MTB format) under the deps folder or use the Library Manager to add it in your project.

In the Makefile of the project, ensure RTOS_AWARE is an enabled component if RTOS is used.
* COMPONENTS=RTOS_AWARE

### Using the library

Include the relevant PSA API header file and refer to [PSA API](https://github.com/ARM-software/psa-arch-tests/tree/master/api-specs)

## More information
The following resources contain more information:
* [Trusted Firmware-M RELEASE.md](./RELEASE.md)
* [PSA API](https://github.com/ARM-software/psa-arch-tests/tree/master/api-specs)
* [ModusToolbox Software Environment, Quick Start Guide, Documentation, and Videos](https://www.cypress.com/products/modustoolbox-software-environment)
* [Cypress Semiconductor](http://www.cypress.com)

© Cypress Semiconductor Corporation, 2021.
