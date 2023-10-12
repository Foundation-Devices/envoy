// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Copyright (c) 2014, the tuple project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

/// ## Usage example
///
/// ```dart
/// const t = const Tuple2<String, int>('a', 10);
///
/// print(t.item1); // prints 'a'
/// print(t.item2); // prints '10'
/// ```
///
/// ```dart
/// const t1 = const Tuple2<String, int>('a', 10);
/// final t2 = t1.withItem1('c');
/// // t2 is a new [Tuple2] object with item1 is 'c' and item2 is 10.
/// ```

/// Represents a 2-tuple, or pair.
class Tuple<T1, T2> {
  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  /// Creates a new tuple value with the specified items.
  const Tuple(this.item1, this.item2);

  /// Create a new tuple value with the specified list [items].
  factory Tuple.fromList(List items) {
    if (items.length != 2) {
      throw ArgumentError('items must have length 2');
    }

    return Tuple<T1, T2>(items[0] as T1, items[1] as T2);
  }

  /// Returns a tuple with the first item set to the specified value.
  Tuple<T1, T2> withItem1(T1 v) => Tuple<T1, T2>(v, item2);

  /// Returns a tuple with the second item set to the specified value.
  Tuple<T1, T2> withItem2(T2 v) => Tuple<T1, T2>(item1, v);

  /// Creates a [List] containing the items of this [Tuple].
  ///
  /// The elements are in item order. The list is variable-length
  /// if [growable] is true.
  List toList({bool growable = false}) =>
      List.from([item1, item2], growable: growable);

  @override
  String toString() => '[$item1, $item2]';

  @override
  bool operator ==(Object other) =>
      other is Tuple && other.item1 == item1 && other.item2 == item2;

  @override
  int get hashCode => Object.hash(item1.hashCode, item2.hashCode);
}
