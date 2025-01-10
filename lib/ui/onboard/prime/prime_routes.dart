// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/onboard/prime/onboard_prime.dart';
import 'package:go_router/go_router.dart';

const ONBOARD_PRIME = "prime";

final primeRoutes = GoRoute(
  path: "prime",
  name: ONBOARD_PRIME,
  builder: (context, state) => const OnboardPrimeWelcome(),
);
