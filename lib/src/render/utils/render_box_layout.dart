import 'dart:ui';

import 'package:flutter/rendering.dart';

extension RenderBoxLayout on RenderBox {
  /// Returns size of render box based on provided [BoxConstraints].
  ///
  /// `dry` flag indicates whether a real layout pass should be
  /// executed on render box. Default value assumes that we don't
  /// want to perform real layout and only get potential size of box.
  Size getLayoutSize(BoxConstraints constraints, {bool dry = true}) {
    final Size childSize;
    if (dry) {
      childSize = this.getDryLayout(constraints);
    } else {
      this.layout(constraints, parentUsesSize: true);
      childSize = this.size;
    }
    return childSize;
  }
}
