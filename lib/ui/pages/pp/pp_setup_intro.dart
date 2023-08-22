// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/pages/pp/pp_new_seed.dart';
import 'package:envoy/ui/pages/pp/pp_restore_backup.dart';
import 'package:envoy/ui/pages/pp/pp_restore_seed.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';

class PpSetupIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_rounded, size: 20),
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil(ModalRoute.withName("/"));
                  },
                  child: Icon(Icons.close_rounded)),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: Offset(0, 100),
          child: Image.asset(
            "assets/pp_setup_intro.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width / 1.3,
            height: MediaQuery.of(context).size.height / 1.3,
          ),
        ),
        bottomNavigationBar: EnvoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(
                  right: 15, left: 15, top: 50, bottom: 50),
              child: SizedBox.expand(
                  child: Container(
                height: max(MediaQuery.of(context).size.height * 0.38, 300),
                margin: EdgeInsets.symmetric(horizontal: 18),
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        width: 380,
                        child: Column(
                          children: [
                            Text(
                              S().envoy_pp_setup_intro_card1_heading,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Padding(padding: EdgeInsets.all(6)),
                            Text(
                              S().envoy_pp_setup_intro_card1_subheading,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          EnvoyButton(
                              type: EnvoyButtonTypes.tertiary,
                              S().envoy_pp_setup_intro_cta3, onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PpRestoreBackupPage();
                            }));
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                          ),
                          EnvoyButton(
                              type: EnvoyButtonTypes.secondary,
                              S().envoy_pp_setup_intro_cta2, onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PpRestoreSeedPage();
                            }));
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                          ),
                          EnvoyButton(S().envoy_pp_setup_intro_cta1, onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PpNewSeedPage();
                            }));
                          }),
                        ],
                      ),
                    )
                  ],
                ),
              ))),
        ),
      ),
    );
  }
}
