import 'package:flutter_test/flutter_test.dart';
import 'package:oxygene/src/genome_short_form.dart';

/// Oxygene должен разворачивать короткую форму `old || buffer | count` в то
/// же дерево, что и интерактивный холст front. mergeAll приватный, поэтому
/// проверяем структурно: баланс (листьев = развилок + 1, одиночных узлов
/// кроме корня нет) и рост дерева с числом повторов.
void main() {
  const life = "0,2-0*11v0,2-0*10v0,3-0*11v0,1-0*a,2-0*a,3-0*a,4-0*a";
  const buffer = "0,3-0*1v11,1-0*a,1-0*a";

  int leaves(String g) => g.split(',').where((t) => t.endsWith('*a')).length;
  int forks(String g) => g.split(',').where((t) => t.contains('v')).length;
  void expectBalanced(String g) =>
      expect(leaves(g), forks(g) + 1, reason: 'разбалансировано: $g');

  test('плоский геном разворачивается в себя (нет ||)', () {
    expect(GenomeShortForm.expand(life), life);
    expect(GenomeShortForm.isShort(life), isFalse);
  });

  test('| 1 врастает буфер во все листья, дерево сбалансировано', () {
    final once = GenomeShortForm.expand('$life || $buffer | 1');
    expect(GenomeShortForm.isShort('$life || $buffer | 1'), isTrue);
    expect(once, isNot(life));
    expect(leaves(once), greaterThan(leaves(life)));
    expectBalanced(once);
  });

  test('счётчик растит дерево монотонно, баланс цел', () {
    final once = GenomeShortForm.expand('$life || $buffer | 1');
    final twice = GenomeShortForm.expand('$life || $buffer | 2');
    final thrice = GenomeShortForm.expand('$life || $buffer | 3');
    expect(leaves(twice), greaterThan(leaves(once)));
    expect(leaves(thrice), greaterThan(leaves(twice)));
    expectBalanced(twice);
    expectBalanced(thrice);
  });

  test('вложенная форма (n+1 эквивалентна обёртке) даёт то же дерево', () {
    // `… | 2` и `(… | 1) || buffer | 1` — одно дерево
    final byCount = GenomeShortForm.expand('$life || $buffer | 2');
    final byNest = GenomeShortForm.expand('$life || $buffer | 1 || $buffer | 1');
    expect(byNest, byCount);
    expectBalanced(byNest);
  });

  test('кривой/нулевой счётчик => 0 повторов, life не меняется', () {
    expect(GenomeShortForm.expand('$life || $buffer | 0'), life);
    expect(GenomeShortForm.expand('$life || $buffer | x'), life);
    expect(GenomeShortForm.expand('$life || $buffer'), life);
  });
}
