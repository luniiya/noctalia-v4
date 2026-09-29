import QtQuick
import QtTest
import "../Helpers/NotchGeometry.js" as NotchGeometry

TestCase {
  name: "NotchGeometry"

  // ----- inset -----

  function test_inset_usesGap() {
    compare(NotchGeometry.inset(1920, 180), 180);
    compare(NotchGeometry.inset(1080, 0), 0);
  }

  function test_inset_clampsSoBarKeepsMinimumLength() {
    // 1920 * 0.8 / 2 = 768
    compare(NotchGeometry.inset(1920, 5000), 768);
    compare(NotchGeometry.inset(1920, 768), 768);
    compare(NotchGeometry.inset(1920, 769), 768);
    var edge = 1504;
    var gap = NotchGeometry.inset(edge, 99999);
    verify(edge - 2 * gap >= edge * NotchGeometry.minBarFraction);
  }

  function test_inset_floorsToWholePixels() {
    compare(NotchGeometry.inset(1920, 12.7), 12);
    compare(NotchGeometry.inset(1001, 5000), 400); // 1001 * 0.4 = 400.4
  }

  function test_inset_handlesBadInput() {
    compare(NotchGeometry.inset(1920, -50), 0);
    compare(NotchGeometry.inset(1920, undefined), 0);
    compare(NotchGeometry.inset(1920, null), 0);
    compare(NotchGeometry.inset(1920, "abc"), 0);
    compare(NotchGeometry.inset(1920, "200"), 200);
    compare(NotchGeometry.inset(0, 180), 0);
    compare(NotchGeometry.inset(-10, 180), 0);
    compare(NotchGeometry.inset(undefined, 180), 0);
  }

  // ----- isVertical -----

  function test_isVertical() {
    verify(NotchGeometry.isVertical("left"));
    verify(NotchGeometry.isVertical("right"));
    verify(!NotchGeometry.isVertical("top"));
    verify(!NotchGeometry.isVertical("bottom"));
    verify(!NotchGeometry.isVertical(undefined));
  }

  // ----- cornerOnScreenEdge -----

  function test_cornerOnScreenEdge_data() {
    return [
      { tag: "top/topLeft", pos: "top", corner: "topLeft", expected: true },
      { tag: "top/topRight", pos: "top", corner: "topRight", expected: true },
      { tag: "top/bottomLeft", pos: "top", corner: "bottomLeft", expected: false },
      { tag: "top/bottomRight", pos: "top", corner: "bottomRight", expected: false },
      { tag: "bottom/topLeft", pos: "bottom", corner: "topLeft", expected: false },
      { tag: "bottom/bottomRight", pos: "bottom", corner: "bottomRight", expected: true },
      { tag: "left/topLeft", pos: "left", corner: "topLeft", expected: true },
      { tag: "left/bottomLeft", pos: "left", corner: "bottomLeft", expected: true },
      { tag: "left/topRight", pos: "left", corner: "topRight", expected: false },
      { tag: "right/topRight", pos: "right", corner: "topRight", expected: true },
      { tag: "right/bottomRight", pos: "right", corner: "bottomRight", expected: true },
      { tag: "right/bottomLeft", pos: "right", corner: "bottomLeft", expected: false },
      { tag: "unknown corner", pos: "top", corner: "middle", expected: false }
    ];
  }

  function test_cornerOnScreenEdge(data) {
    compare(NotchGeometry.cornerOnScreenEdge(data.corner, data.pos), data.expected);
  }

  // ----- cornerEnd -----

  function test_cornerEnd_data() {
    return [
      { tag: "top/topLeft", pos: "top", corner: "topLeft", expected: "start" },
      { tag: "top/bottomLeft", pos: "top", corner: "bottomLeft", expected: "start" },
      { tag: "top/topRight", pos: "top", corner: "topRight", expected: "end" },
      { tag: "bottom/bottomRight", pos: "bottom", corner: "bottomRight", expected: "end" },
      { tag: "left/topLeft", pos: "left", corner: "topLeft", expected: "start" },
      { tag: "left/topRight", pos: "left", corner: "topRight", expected: "start" },
      { tag: "left/bottomLeft", pos: "left", corner: "bottomLeft", expected: "end" },
      { tag: "right/bottomRight", pos: "right", corner: "bottomRight", expected: "end" }
    ];
  }

  function test_cornerEnd(data) {
    compare(NotchGeometry.cornerEnd(data.corner, data.pos), data.expected);
  }

  // ----- cornerState -----

  function test_cornerState_data() {
    return [
      // Horizontal bars flare along X on the screen edge
      { tag: "top/topLeft/outer", pos: "top", corner: "topLeft", outer: true, expected: 1 },
      { tag: "top/topRight/outer", pos: "top", corner: "topRight", outer: true, expected: 1 },
      { tag: "top/bottomLeft/outer", pos: "top", corner: "bottomLeft", outer: true, expected: 0 },
      { tag: "bottom/bottomLeft/outer", pos: "bottom", corner: "bottomLeft", outer: true, expected: 1 },
      { tag: "bottom/topRight/outer", pos: "bottom", corner: "topRight", outer: true, expected: 0 },
      // Vertical bars flare along Y
      { tag: "left/topLeft/outer", pos: "left", corner: "topLeft", outer: true, expected: 2 },
      { tag: "left/topRight/outer", pos: "left", corner: "topRight", outer: true, expected: 0 },
      { tag: "right/bottomRight/outer", pos: "right", corner: "bottomRight", outer: true, expected: 2 },
      // Without outer corners the screen-edge corners are flat, the rest stay rounded
      { tag: "top/topLeft/flat", pos: "top", corner: "topLeft", outer: false, expected: -1 },
      { tag: "top/bottomRight/flat", pos: "top", corner: "bottomRight", outer: false, expected: 0 },
      { tag: "left/bottomLeft/flat", pos: "left", corner: "bottomLeft", outer: false, expected: -1 }
    ];
  }

  function test_cornerState(data) {
    compare(NotchGeometry.cornerState(data.corner, data.pos, data.outer), data.expected);
  }

  // ----- fillInsets -----

  function test_fillInsets_noPanelKeepsGaps() {
    var r = NotchGeometry.fillInsets(180, 1920, false, 0, 1920, 20);
    compare(r.start, 180);
    compare(r.end, 180);
  }

  function test_fillInsets_panelInMiddleKeepsGaps() {
    var r = NotchGeometry.fillInsets(180, 1920, true, 600, 1300, 20);
    compare(r.start, 180);
    compare(r.end, 180);
  }

  function test_fillInsets_panelPastStartFillsStartOnly() {
    var r = NotchGeometry.fillInsets(180, 1920, true, 0, 700, 20);
    compare(r.start, 0);
    compare(r.end, 180);
  }

  function test_fillInsets_panelPastEndFillsEndOnly() {
    var r = NotchGeometry.fillInsets(180, 1920, true, 1200, 1920, 20);
    compare(r.start, 180);
    compare(r.end, 0);
  }

  function test_fillInsets_widePanelFillsBothEnds() {
    var r = NotchGeometry.fillInsets(180, 1920, true, 50, 1870, 20);
    compare(r.start, 0);
    compare(r.end, 0);
  }

  function test_fillInsets_panelInsideCornerCurveFills() {
    // Starts after the gap but inside the bar's corner radius
    var r = NotchGeometry.fillInsets(180, 1920, true, 190, 700, 20);
    compare(r.start, 0);
    // Exactly at gap + radius is clear of the curve
    r = NotchGeometry.fillInsets(180, 1920, true, 200, 700, 20);
    compare(r.start, 180);
  }

  function test_fillInsets_endBoundary() {
    var r = NotchGeometry.fillInsets(180, 1920, true, 1000, 1720, 20);
    compare(r.end, 180);
    r = NotchGeometry.fillInsets(180, 1920, true, 1000, 1721, 20);
    compare(r.end, 0);
  }

  function test_fillInsets_zeroGap() {
    var r = NotchGeometry.fillInsets(0, 1920, true, 0, 1920, 20);
    compare(r.start, 0);
    compare(r.end, 0);
  }

  function test_fillInsets_missingRadiusTreatedAsZero() {
    var r = NotchGeometry.fillInsets(180, 1920, true, 180, 700);
    compare(r.start, 180);
    r = NotchGeometry.fillInsets(180, 1920, true, 179, 700);
    compare(r.start, 0);
  }
}
