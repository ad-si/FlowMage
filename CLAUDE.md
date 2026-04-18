# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `make build-ext` — build the FlatCV GDExtension. The `SConstruct` clones `godot-cpp` and `FlatCV` at pinned commits into `addons/flatcv/` on first run, then compiles `libflatcv.<platform>.<target>.<arch>.<ext>` into `addons/flatcv/bin/`. Re-run after changing C/C++ sources.
- `make format` — format all GDScript with `gdformat` (2-space indent). Apply before committing GDScript changes.
- `godot --path .` — run the editor/game.
- `godot --path . --headless --script addons/flatcv/test_flatcv.gd` — smoke-test that the FlatCV extension loaded and `FlatCV.rgba_to_grayscale` works.
- Godot 4.6+ is required (`compatibility_minimum = "4.6"` in `flatcv.gdextension`, `config/features=PackedStringArray("4.6")` in `project.godot`).

## Architecture

The app is a thin Godot scene tree wrapping a `GraphEdit` node-graph editor that drives image processing.

**Scene layout** (`Main.tscn`): `Panel` → `HSplitContainer` → (`GraphEdit` with `Show` sink node + `NodeSelector` popup) | `TextureRect` (preview pane). `Main.gd` only handles HiDPI window sizing.

**Evaluation model** (`graph.gd`):
- The graph is pull-evaluated from a single `Show` sink node. Any change (connect, disconnect, node add, pass-through toggle, file pick) calls `trigger_image_synthesis()`, which walks back from `Show` via `_evaluate_node()` recursively, calling each node's `evaluate(input_image)` and feeding the result to `TextureRect.render_image()`.
- Only one connection into `Show` is permitted; `_on_GraphEdit_connection_request` enforces this by disconnecting any prior edge.
- `graph_nodes` is the registry of node types available in the right-click `NodeSelector` popup. To add a node type: create `GraphNodes/Foo.tscn` + `foo.gd` extending `flow_node.gd`, then append `{"name": "Category/Foo", "scene": preload(...)}` to `graph_nodes`.

**FlowNode base class** (`GraphNodes/flow_node.gd`):
- All graph nodes extend `FlowNode` (which extends `GraphNode`).
- Subclasses override `_evaluate_internal(input)` — never `evaluate()` directly. The base `evaluate()` short-circuits to the input when `pass_through` is on (toggled via the ⇥ titlebar button — only shown when the node has inputs).
- The titlebar auto-builds buttons: pass-through (if it has inputs), replace (↻, emits `replace_requested`), docs (?), delete (✕). Replace re-uses the `NodeSelector` popup and preserves connections in `_transfer_connections` where port indices still fit.
- Override `get_documentation()` to populate the ? dialog.
- After mutating the graph, GDScript nodes call `get_parent().trigger_image_synthesis()` (or `call_deferred(...)` from `_on_delete_pressed` since the node is being freed).

**FlatCV GDExtension** (`addons/flatcv/`):
- C++ wrapper (`src/flatcv_wrapper.cpp`, `register_types.cpp`) exposes the C library [FlatCV](https://github.com/ad-si/FlatCV) as a Godot `FlatCV` singleton class. Methods take/return `Image`.
- `SConstruct` pins both `godot-cpp` and `FlatCV` to specific commits — bump those constants to upgrade. The `flatcv/` and `godot-cpp/` source trees are gitignored under `addons/flatcv/`.
- Image processing nodes call e.g. `FlatCV.rgba_to_grayscale(input)`. Adding new image ops means extending the C++ wrapper and rebuilding with `make build-ext`.
