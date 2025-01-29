// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

/// State of the onboarding process after successful pairing
enum PrimeSetupState {
  PIN,
  CREATE_SEED,
  RESTORE_SEED,
  MAGIC_BACKUP,
  MANUAL_BACKUP,
  FINISH
}
