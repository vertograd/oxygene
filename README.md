# Oxygene

A read-only Flutter widget that renders an L-system / turtle-graphics tree from
a compact **genome** string. You hand it one string; it unrolls the string into
a branching tree and fits the drawing to its box. The widget is non-interactive
by design — no taps, no gestures — so it is safe to drop into cards, previews,
lists, or full-screen views.

## Live gallery & editor

See it in action at **[limenhort.com/oxygene](https://limenhort.com/oxygene)**.
The site has an editor for building your own trees and a gallery of ready-made
examples. Each example shows its genome string, so you can copy one and paste it
straight into the `genome:` argument below.

## Features

- Single public widget — `Oxygene` — with a tiny, stable API.
- Accepts both the plain genome form and the compact **short form**
  (`<old> || <buffer> | <count>`); the widget expands the short form itself.
- Fits the tree to the available space; draws nothing of its own around it
  (border, background, and clipping are the caller's responsibility — wrap it in
  a `Container` if you want a frame).
- Invalid genomes fail soft: a structural error yields a truncated or blank
  tree, never a thrown exception.

## Getting started

Add it to your app's `pubspec.yaml`:

```yaml
dependencies:
  oxygene: ^1.0.0
```

Or run:

```bash
flutter pub add oxygene
```

## Usage

```dart
import 'package:oxygene/oxygene.dart';

// paste a genome copied from the gallery at limenhort.com/oxygene
Oxygene(genome: '0,1-0*3v9,1-0*a,1-0*a');
```

### Parameters

| Parameter         | Type     | Default        | Description                                              |
| ----------------- | -------- | -------------- | -------------------------------------------------------- |
| `genome`          | `String` | required       | The genome string (plain or short form).                 |
| `width`           | `double?`| `null`         | Box width; falls back to the parent's constraints.       |
| `height`          | `double?`| `null`         | Box height; falls back to the parent's constraints.      |
| `backgroundColor` | `Color`  | `Colors.white` | Fill behind the tree.                                    |
| `leafScale`       | `double` | `2.0`          | Size multiplier for leaf (branch-tip) markers.           |

## Genome format

A genome is a comma-separated list of tokens, e.g.
`0,2-0*11v0,1-0*a,2-0*a`. Each token is `tail-?*head`:

- **`tail`** (before `-`) — segment length / distance to the child.
- **`head`** (after `*`):
  - a single number `0–11` — a node with one child; the number is a direction on
    a 12-hour clock.
  - `LvR` (two distinct numbers) — a fork with two children.
  - `a` — a leaf (branch tip).

Directions are cumulative and relative: a child's angle is added to its
ancestor's, modulo 12.

**Short form.** A genome may also be written compactly as
`<old> || <buffer> | <count>`, meaning "graft `buffer` into every leaf of `old`,
`count` times." `Oxygene` expands this for you, so either form can be passed to
`genome:`.

## Additional information

- Source & issues: <https://github.com/limenhort/oxygene>
- Live demo: <https://limenhort.com/oxygene>
