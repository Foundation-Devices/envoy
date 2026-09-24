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

  test('grid drag scrolls only near viewport edges', () {
    expect(
      gridAutoScrollOffset(
        currentOffset: 100,
        minOffset: 0,
        maxOffset: 200,
        pointerY: 20,
        viewportHeight: 400,
      ),
      76,
    );
    expect(
      gridAutoScrollOffset(
        currentOffset: 100,
        minOffset: 0,
        maxOffset: 200,
        pointerY: 200,
        viewportHeight: 400,
      ),
      100,
    );
    expect(
      gridAutoScrollOffset(
        currentOffset: 190,
        minOffset: 0,
        maxOffset: 200,
        pointerY: 390,
        viewportHeight: 400,
      ),
      200,
    );
  });

  test('account grid requires multiple accounts in landscape', () {
    expect(
      useAccountsGrid(
        accountCount: 1,
        availableWidth: 800,
        availableHeight: 500,
      ),
      isFalse,
    );
    expect(
      useAccountsGrid(
        accountCount: 2,
        availableWidth: 800,
        availableHeight: 500,
      ),
      isTrue,
    );
    expect(
      useAccountsGrid(
        accountCount: 2,
        availableWidth: 500,
        availableHeight: 800,
      ),
      isFalse,
    );
  });
}
