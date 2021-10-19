# Cypress Customized Trusted Firmware-M Release Notes

## What's Included?
1. TF-M implementation with support of the following services:
  * Crypto
  * Initial Attestation
  * Internal Trusted Storage
  * Platform
  * Protected Storage
2. Support for dual core PSoC® 64 device and cy8ckit-064s0s2-4343w reference board
3. PSoC® 64 reference policies and sample image signing keys
4. Helper script to facilitate device re-provisioning
5. PSoC® 64 specific regression tests
6. Detailed PSoC® 64 specific documentation

See the [README.md](./README.md) for an additional description of the TF-M software.

## Changelog

### v1.3.1
* Update to PDL v2.3.0

### v1.3.0
* Update to TFM v1.3.0 from trustedfirmware.org
* Update to PDL v2.2.0
* Update to use p64_utils v1.0.0

### v1.2.0
* Update to TFM v1.2.0 from trustedfirmware.org
* Update to PDL v1.6.1

### v1.0.0
* Initial release for TF-M

## Known Issues
n/a

## Supported Platforms
This library and its features are supported on the following Cypress platforms:
* [PSoC® 64 Standard Secure - AWS Wi-Fi BT Pioneer Kit (CY8CKIT-064S0S2-4343W)](https://www.cypress.com/documentation/development-kitsboards/psoc-64-standard-secure-aws-wi-fi-bt-pioneer-kit-cy8ckit)

## Supported Software and Tools

This version of TF-M was validated for compatibility with the following Software and Tools:

| Software and Tools                                                            | Version       |
| :---                                                                          | :----         |
| ModusToolbox Software Environment                                             | 2.3.0         |
| GCC Compiler                                                                  | 9.3.1         |
| ARM Compiler 6                                                                | 6.13          |
| CMake                                                                         | 3.15          |
| CMSIS-Core(M)                                                                 | 5.5.0         |
| MbedTLS                                                                       | 2.25.0        |
| Board Support Package (BSP)                                                   | 2.3.0         |
| PSoC 6 Peripheral Driver Library (PDL)                                        | 2.3.0         |
| RTOS Abstraction                                                              | 1.4.0         |

Minimum required ModusToolbox Software Environment: v2.3.0

## More information
Use the following links for more information, as needed:
* [Cypress Semiconductor, an Infineon Technologies Company](http://www.cypress.com)
* [Cypress Semiconductor GitHub](https://github.com/cypresssemiconductorco)
* [PSoC® 64 Secure Microcontrollers](https://www.cypress.com/products/32-bit-arm-cortex-m4-cortex-m0-psoc-64-security-line)
* [Trusted Firmware website](https://www.trustedfirmware.org)
* [TF-M project](https://www.trustedfirmware.org/projects/tf-m)

---
© Cypress Semiconductor Corporation, 2021.
