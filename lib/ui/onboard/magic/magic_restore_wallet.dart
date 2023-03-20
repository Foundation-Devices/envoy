// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:flutter/material.dart';

class MagicCreateWallet extends StatefulWidget {
  const MagicCreateWallet({Key? key}) : super(key: key);

  @override
  State<MagicCreateWallet> createState() => _MagicCreateWalletState();
}

class _MagicCreateWalletState extends State<MagicCreateWallet> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      child: Material(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Enter Your Seed",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
          color: Colors.transparent),
    );
  }
}
