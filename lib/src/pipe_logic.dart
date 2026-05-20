import 'dart:math' as math;
import 'dart:ui';

class PipeCoord {
  final double x;
  final double y;

  PipeCoord({required this.x, required this.y});

  static PipeCoord calcCoord(PipeCoord prevCoord, int spin, int hvost) {
    double rad = (spin / 6) * math.pi;

    double x = math.cos(rad);
    double y = math.sin(rad);

    if (hvost == 0) {
      x = (x * 3);
      y = (y * 3);
    } else {
      x = (x * 10 * hvost);
      y = (y * 10 * hvost);
    }

    return PipeCoord(x: prevCoord.x + x, y: prevCoord.y + y);
  }

  @override
  String toString() => '${x.toString()} ${y.toString()}';
}

class PipeSlot {
  final int spin;
  final PipeCoord coord;

  PipeSlot({required this.spin, required this.coord});

  static PipeSlot calcSpin(
    String currentSpinStr,
    PipeCoord currentCoord,
    int ancestorSpin,
  ) {
    final spin = spinMerge(currentSpinStr, ancestorSpin);

    return PipeSlot(spin: spin, coord: currentCoord);
  }

  static int spinMerge(String currentSpinStr, int ancestorSpin) {
    var currentSpin = int.parse(currentSpinStr);
    int sum = currentSpin + ancestorSpin;
    int spin;
    if (sum > 11) {
      spin = sum - 12;
    } else {
      spin = sum;
    }
    return spin;
  }

  @override
  String toString() => 's:${spin.toString()}c:${coord.toString()}';
}

class PipeStack {
  final _list = <PipeSlot>[];

  void push(PipeSlot value) => _list.add(value);

  PipeSlot pop() => _list.removeAt(0);

  PipeSlot get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() {
    String str = '';
    for (final item in _list) {
      str += item.toString();
      str += ' | ';
    }
    return str;
  }
}

class PipeLogic {
  final stack = PipeStack();

  PipeCoord? currentCoord;
  PipeCoord? ancestorCoord;

  Offset? ancestorOffset(Size size) {
    if (ancestorCoord == null) {
      return null;
    }
    return Offset(
      ancestorCoord!.x + size.width / 2,
      ancestorCoord!.y + size.height - (size.height / 12),
    );
  }

  Offset currentOffset(Size size) {
    return Offset(
      currentCoord!.x + size.width / 2,
      currentCoord!.y + size.height - (size.height / 12),
    );
  }

  addKnot(String knot) {
    if (stack.isEmpty) {
      _addZerroKnot(knot);
      return;
    }

    _addNextKnot(knot);
  }

  addList(String knot) {
    PipeSlot mySlot = stack.pop();

    int hvost = _calcHvost(knot);

    PipeCoord myCoord = PipeCoord.calcCoord(mySlot.coord, mySlot.spin, hvost);

    ancestorCoord = mySlot.coord;
    currentCoord = myCoord;
  }

  bool isKnot(String knot) {
    if (_is12not6(knot) || knot == '6') return true;

    List<String> listHvostHead = knot.split("*");

    if (listHvostHead.length == 2) {
      String head = listHvostHead[1];

      if (_is12not6(head)) {
        return true;
      }

      List<String> listLSlotRSlot = head.split("v");
      if (listLSlotRSlot.length == 2) {
        String lSlot = listLSlotRSlot[0];
        String rSlot = listLSlotRSlot[1];
        if (_is12not6(lSlot) && _is12not6(rSlot) && (lSlot != rSlot)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _is12not6(String str) {
    if (str == '1' || str == '2' || str == '3' || str == '4') return true;
    if (str == '5' || str == '7' || str == '8') return true;
    if (str == '9' || str == '10' || str == '11' || str == '0') return true;
    return false;
  }

  _addZerroKnot(String knot) {
    currentCoord = PipeCoord(x: 0, y: 0);
    ancestorCoord = null;
    int ancestorSpin = 0;
    final spin = PipeSlot.spinMerge(knot, 9);
    final slot1 = PipeSlot.calcSpin(
      spin.toString(),
      currentCoord!,
      ancestorSpin,
    );
    stack.push(slot1);
  }

  _addNextKnot(String knot) {
    PipeSlot mySlot = stack.pop();

    int hvost = _calcHvost(knot);

    PipeCoord myCoord = PipeCoord.calcCoord(mySlot.coord, mySlot.spin, hvost);

    ancestorCoord = mySlot.coord;
    currentCoord = myCoord;

    int ancestorSpin = mySlot.spin;

    List<String> listHvostHead = knot.split("*");
    if (listHvostHead.length == 2) {
      String head = listHvostHead[1];
      if (_is12not6(head)) {
        final slot1 = PipeSlot.calcSpin(head, currentCoord!, ancestorSpin);
        stack.push(slot1);
      }

      List<String> listLSlotRSlot = head.split("v");
      if (listLSlotRSlot.length == 2) {
        String lSlot = listLSlotRSlot[0];
        String rSlot = listLSlotRSlot[1];

        final slot1 = PipeSlot.calcSpin(lSlot, currentCoord!, ancestorSpin);
        stack.push(slot1);
        final slot2 = PipeSlot.calcSpin(rSlot, currentCoord!, ancestorSpin);
        stack.push(slot2);
      }
    }
  }

  int _calcHvost(String knot) {
    List<String> listHvost = knot.split("-");
    String hvostStr = listHvost[0];
    return int.parse(hvostStr);
  }
}
