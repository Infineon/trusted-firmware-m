/*
 * Copyright (c) 2020-2021, Arm Limited. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef _TFM_MAILBOX_CONFIG_
#define _TFM_MAILBOX_CONFIG_

/*
 * \note Don't modify this file. Change the build configuration value
 *       and re-build TF-M SPE side to update the value.
 */

/* Get number of mailbox queue slots from build configuration */
#define NUM_MAILBOX_QUEUE_SLOT 4

#ifndef NUM_MAILBOX_QUEUE_SLOT
#define NUM_MAILBOX_QUEUE_SLOT              1
#endif

#if (NUM_MAILBOX_QUEUE_SLOT < 1)
#error "Error: Invalid NUM_MAILBOX_QUEUE_SLOT. The value should be >= 1"
#endif

/*
 * The number of slots should be no more than the number of bits in
 * mailbox_queue_status_t.
 * Here the value is hardcoded. A better way is to define a sizeof() to
 * calculate the bits in mailbox_queue_status_t and dump it with pragma message.
 */
#if (NUM_MAILBOX_QUEUE_SLOT > 32)
#error "Error: Invalid NUM_MAILBOX_QUEUE_SLOT. The value should be <= 32"
#endif

#endif /* _TFM_MAILBOX_CONFIG_ */
