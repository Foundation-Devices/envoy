// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grid reorder preserves hidden accounts', () {
    expect(
      reorderAccountIds(
        order: [],
        visibleIds: ['a', 'b'],
        oldIndex: 1,
        newIndex: 0,
      ),
      ['b', 'a'],
    );
    expect(
      reorderAccountIds(
        order: ['a', 'hidden', 'b', 'c'],
        visibleIds: ['a', 'b', 'c'],
        oldIndex: 0,
        newIndex: 2,
      ),
      ['b', 'c', 'a', 'hidden'],
    );
  });
}
