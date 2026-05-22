/// Короткая форма генома — компактная запись итерируемой L-системы.
///
/// Зеркало `front/lib/service/genome_short_form.dart`, но РЕНДЕР-ОНЛИ:
/// здесь есть только [expand] (развернуть для отрисовки). `wrap` —
/// поведение кнопки 263, то есть редактирование генома, — в oxygene не
/// нужен (пакет ничего не редактирует, см. CLAUDE.md).
///
/// Синтаксис: `<old> || <buffer> | <count>` означает «привить `<buffer>`
/// во все листья `<old>` ровно `<count>` раз» (повторный `mergeAll`).
/// `<old>` сам может быть короткой формой, поэтому в строке бывает
/// несколько `||`; внешняя обёртка — самая правая, разбор рекурсивен и
/// идёт по ПОСЛЕДНЕМУ `||`, затем по последнему `|` (`<buffer>` —
/// обычный плоский геном без `||`/`|`).
///
/// `mergeAll` и хелперы `_Node`/`_parse`/... ниже скопированы из
/// `front/lib/service/merger.dart` (приватный [_GenomeMerger]): превью
/// обязано рисовать те же деревья, что интерактивный холст front, поэтому
/// логику держим побайтово-совместимой и синхронизируем обе копии.
class GenomeShortForm {
  static const String _graftSep = '||';
  static const String _countSep = '|';

  /// true, если строка — короткая форма (содержит разделитель прививки).
  static bool isShort(String s) => s.contains(_graftSep);

  /// Разворачивает короткую форму в полный (плоский) геном. Плоский геном
  /// возвращается как есть. Метод не бросает: кривой счётчик => 0 повторов,
  /// кривой буфер глотает сам `mergeAll`.
  static String expand(String s) {
    final trimmed = s.trim();

    /// внешняя обёртка — по последнему `||`; левая часть может содержать
    /// вложенные короткие формы и разбирается рекурсивно
    final cut = trimmed.lastIndexOf(_graftSep);
    if (cut < 0) return trimmed; // плоский геном — разворачивать нечего

    final leftStr = trimmed.substring(0, cut);
    final rightStr = trimmed.substring(cut + _graftSep.length);

    /// правая часть `buffer | count`: буфер без `|`, делим по последнему `|`.
    /// Нет `|` — обёртка без счётчика, игнорируем хвост.
    final bar = rightStr.lastIndexOf(_countSep);
    if (bar < 0) return expand(leftStr);

    final bufferStr = rightStr.substring(0, bar);
    final countStr = rightStr.substring(bar + _countSep.length);
    final count = int.tryParse(countStr.trim()) ?? 0;

    var life = expand(leftStr);
    final buffer = expand(bufferStr);

    final merger = _GenomeMerger();
    for (var i = 0; i < count; i++) {
      life = merger.mergeAll(life: life, part: buffer);
    }
    return life;
  }
}

/// Приватная копия `mergeAll` из `front/lib/service/merger.dart` (только
/// то, что нужно для [GenomeShortForm.expand] — без редактирующих
/// merge/deleteLeaf/resizeStem). Держать поведение идентичным front-копии.
class _GenomeMerger {
  /// Прививает буфер-поддерево сразу во все листья генома. Листья собираем
  /// до мутации, чтобы не врастать в только что привитые поддеревья. Баланс
  /// стека сохраняется: лист и самозамкнутое поддерево оба дают баланс −1.
  String mergeAll({required String life, required String part}) {
    final tokens = life.split(',').where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return life;

    final order = <_Node>[];
    final root = _parse(tokens, isGenomeRoot: true, order: order);
    if (root == null) return life;

    final subtreeTokens = _stripRotation(part);
    if (subtreeTokens.isEmpty) return life;

    final leaves = order.where((n) => n.children.isEmpty).toList();
    for (final leaf in leaves) {
      /// свежий разбор на каждый лист — узлы _Node мутабельны, общий
      /// граф детей нельзя переиспользовать
      final graft = _parse(subtreeTokens, isGenomeRoot: false, order: <_Node>[]);
      if (graft == null) continue;
      /// tail листа → tail привитого корня
      leaf.token = _withTailOf(leaf.token, graft.token);
      leaf.children
        ..clear()
        ..addAll(graft.children);
    }
    return _serialize(root);
  }

  /// Строим дерево в порядке BFS — ровно как `PipeLogic` ест свою очередь.
  _Node? _parse(
    List<String> tokens, {
    required bool isGenomeRoot,
    required List<_Node> order,
  }) {
    if (tokens.isEmpty) return null;

    final root = _Node(tokens[0]);
    order.add(root);

    final queue = <_Node>[];
    final rootArity = isGenomeRoot ? 1 : _arity(tokens[0]);
    for (int k = 0; k < rootArity; k++) {
      queue.add(root);
    }

    int ti = 1;
    while (queue.isNotEmpty && ti < tokens.length) {
      final parent = queue.removeAt(0);
      final node = _Node(tokens[ti]);
      order.add(node);
      node.parent = parent;
      parent.children.add(node);
      for (int k = 0; k < _arity(tokens[ti]); k++) {
        queue.add(node);
      }
      ti++;
    }
    return root;
  }

  /// Обратно в строку тем же BFS-обходом, что разбирает `PipeLogic`.
  String _serialize(_Node root) {
    final out = <String>[];
    final queue = <_Node>[root];
    while (queue.isNotEmpty) {
      final n = queue.removeAt(0);
      out.add(n.token);
      queue.addAll(n.children);
    }
    return out.join(',');
  }

  /// Возвращает токен `donor`, у которого tail заменён на tail из `source`.
  String _withTailOf(String source, String donor) {
    final srcDash = source.indexOf('-');
    final dstDash = donor.indexOf('-');
    if (srcDash < 0 || dstDash < 0) return donor;
    return '${source.substring(0, srcDash)}${donor.substring(dstDash)}';
  }

  /// Срезает ведущий токен «начального поворота» буфера — он нужен только
  /// для standalone-превью; при прививке корень буфера задаётся первым
  /// настоящим узлом.
  List<String> _stripRotation(String part) {
    final tokens = part.split(',').where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return tokens;
    return tokens.sublist(1);
  }

  /// Сколько детей у токена: голова-число => 1, `LvR` (разные числа) => 2,
  /// иначе (`a`) => 0.
  int _arity(String token) {
    final parts = token.split('*');
    if (parts.length != 2) return 0;
    final head = parts[1];
    if (_isNum(head)) return 1;
    final lr = head.split('v');
    if (lr.length == 2 && _isNum(lr[0]) && _isNum(lr[1]) && lr[0] != lr[1]) {
      return 2;
    }
    return 0;
  }

  /// число часов 0–11 без 6 (слот 6 всегда занят хвостом)
  bool _isNum(String s) {
    const ok = {
      '0', '1', '2', '3', '4', '5', '7', '8', '9', '10', '11',
    };
    return ok.contains(s);
  }
}

class _Node {
  String token;
  _Node? parent;
  final List<_Node> children = [];
  _Node(this.token);
}
