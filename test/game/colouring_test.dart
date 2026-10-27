import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/game/colouring.dart';

/// A 100 × 60 page: a line down the middle (x = 50), and a small 6 × 6
/// box and a 5 × 5 box closed off in the left half.
RegionMap _page() {
  const w = 100, h = 60;
  final line = Uint8List(w * h);
  void mark(int x, int y) => line[y * w + x] = 1;
  for (var y = 0; y < h; y++) {
    mark(50, y);
  }
  void box(int l, int t, int size) {
    for (var i = l; i <= l + size; i++) {
      mark(i, t);
      mark(i, t + size);
    }
    for (var i = t; i <= t + size; i++) {
      mark(l, i);
      mark(l + size, i);
    }
  }

  box(10, 10, 7);
  box(25, 10, 6);
  return RegionMap.label(line, w, h);
}

int _alphaAt(ColouringCanvas c, int x, int y) => c.pixels[(y * c.width + x) * 4 + 3];

void main() {
  test('parts are the areas the lines close in', () {
    final map = _page();
    expect(map.count, 4);
    expect(map.at(5, 5), isNot(map.at(70, 5)), reason: 'left and right of the line');
    expect(map.at(13, 13), isNot(map.at(5, 5)), reason: 'inside a box');
    expect(map.at(50, 30), anyOf(map.at(49, 30), map.at(51, 30)), reason: 'line pixels join a neighbour');
    expect(map.isSmall(map.at(13, 13)), isTrue);
    expect(map.isSmall(map.at(70, 5)), isFalse);
  });

  test('fill colours exactly one part', () {
    final c = ColouringCanvas(_page());
    expect(c.isEmpty, isTrue);
    expect(c.fill(70, 30, 0xFF0000), isTrue);
    expect(_alphaAt(c, 99, 59), 255);
    expect(_alphaAt(c, 5, 5), 0);
    expect(c.pixels[(30 * 100 + 70) * 4], 255, reason: 'red');
    expect(c.isEmpty, isFalse);
  });

  test('a scribble stays in the big part it started in', () {
    final c = ColouringCanvas(_page(), random: math.Random(1));
    c
      ..begin(ColouringTool.paint, 40, 30, 0x00FF00)
      ..moveTo(60, 30)
      ..end();
    expect(_alphaAt(c, 45, 30), greaterThan(0));
    expect(_alphaAt(c, 55, 30), 0, reason: 'never crosses the line');
  });

  test('a scribble that starts in a small part may cross into other small parts only', () {
    final c = ColouringCanvas(_page(), random: math.Random(1));
    c
      ..begin(ColouringTool.paint, 13, 13, 0x0000FF)
      ..moveTo(28, 13)
      ..end();
    expect(_alphaAt(c, 13, 14), greaterThan(0));
    expect(_alphaAt(c, 28, 14), greaterThan(0), reason: 'the other small box');
    expect(_alphaAt(c, 21, 13), 0, reason: 'not the big part between them');
  });

  test('paint is see-through and does not darken within one stroke', () {
    final c = ColouringCanvas(_page());
    c
      ..begin(ColouringTool.paint, 70, 30, 0xFF0000)
      ..moveTo(75, 30)
      ..moveTo(70, 30)
      ..end();
    final once = _alphaAt(c, 70, 30);
    expect(once, lessThan(200));
    c
      ..begin(ColouringTool.paint, 70, 30, 0xFF0000)
      ..end();
    expect(_alphaAt(c, 70, 30), greaterThan(once), reason: 'a new stroke goes darker');
  });

  test('crayon leaves a grainy mark; eraser and undo take colour away', () {
    final c = ColouringCanvas(_page(), random: math.Random(2));
    c
      ..begin(ColouringTool.crayon, 70, 30, 0xFFC93C)
      ..moveTo(90, 30)
      ..end();
    var coloured = 0;
    for (var x = 66; x < 95; x++) {
      for (var y = 22; y < 39; y++) {
        if (_alphaAt(c, x, y) > 0) coloured++;
      }
    }
    expect(coloured, greaterThan(100));
    expect(coloured, lessThan(29 * 17), reason: 'grainy, not solid');

    c
      ..begin(ColouringTool.eraser, 80, 30, 0)
      ..end();
    expect(_alphaAt(c, 80, 30), 0);
    c.undo();
    c.undo();
    expect(c.isEmpty, isTrue);
  });

  test('start again clears, and can be undone', () {
    final c = ColouringCanvas(_page())..fill(5, 5, 0x123456);
    c.clear();
    expect(c.isEmpty, isTrue);
    c.undo();
    expect(c.isEmpty, isFalse);
  });
}
