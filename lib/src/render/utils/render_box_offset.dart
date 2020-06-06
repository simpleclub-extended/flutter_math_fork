import 'dart:ui';

import 'package:flutter/rendering.dart';

extension RenderBoxOffsetExt on RenderBox {
  Offset get offset => (this.parentData as BoxParentData).offset;
  set offset(Offset value) {
    (this.parentData as BoxParentData).offset = value;
  }

  double get height => this.getDistanceToBaseline(TextBaseline.alphabetic);

  double get depth =>
      this.size.height - this.getDistanceToBaseline(TextBaseline.alphabetic);
}
