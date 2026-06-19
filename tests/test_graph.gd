# Tests for graph.gd's Show-node composition logic.
extends "res://tests/test_case.gd"

const GraphScript := preload("res://graph.gd")


func _img(w := 10, h := 8, color := Color.RED) -> Image:
  var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
  image.fill(color)
  return image


# graph.gd extends GraphEdit; instantiated standalone (never entered into the
# tree) the pure composition helpers can be exercised without _ready running.
func _graph():
  return GraphScript.new()


func test_compose_empty_is_null() -> void:
  var g = _graph()
  assert_null(g._compose_show_output([null, null, null, null]))
  g.free()


func test_compose_single_passes_through() -> void:
  var g = _graph()
  var a := _img(10, 8)
  var out = g._compose_show_output([a, null, null, null])
  assert_same(out, a)
  g.free()


func test_compose_same_row_is_side_by_side() -> void:
  # Slots 0 and 1 share a row -> placed horizontally.
  var g = _graph()
  var out = g._compose_show_output([_img(10, 8), _img(10, 8, Color.BLUE), null, null])
  assert_eq(out.get_width(), 20)
  assert_eq(out.get_height(), 8)
  g.free()


func test_compose_different_row_is_stacked() -> void:
  # Slots 0 and 2 are in different rows -> stacked vertically.
  var g = _graph()
  var out = g._compose_show_output([_img(10, 8), null, _img(10, 8, Color.BLUE), null])
  assert_eq(out.get_width(), 10)
  assert_eq(out.get_height(), 16)
  g.free()


func test_compose_four_inputs_is_grid() -> void:
  var g = _graph()
  var out = g._compose_show_output([_img(10, 8), _img(10, 8), _img(10, 8), _img(10, 8)])
  assert_eq(out.get_width(), 20)
  assert_eq(out.get_height(), 16)
  g.free()


func test_prepare_cell_resizes_to_target() -> void:
  var g = _graph()
  var cell = g._prepare_cell(_img(5, 5), 10, 8, Image.FORMAT_RGBA8)
  assert_eq(cell.get_width(), 10)
  assert_eq(cell.get_height(), 8)
  g.free()


func test_prepare_cell_converts_format() -> void:
  var g = _graph()
  var l8 := Image.create(10, 8, false, Image.FORMAT_L8)
  var cell = g._prepare_cell(l8, 10, 8, Image.FORMAT_RGBA8)
  assert_eq(cell.get_format(), Image.FORMAT_RGBA8)
  g.free()


func test_graph_nodes_registry_is_populated() -> void:
  # Sanity check that every transform got registered with a scene + colour.
  assert_true(GraphScript.graph_nodes.size() >= 25, "expected the full node set")
  for entry in GraphScript.graph_nodes:
    assert_true(entry.has("name") and entry.has("scene"), "malformed entry %s" % entry)
    assert_not_null(entry["scene"], "null scene for %s" % entry.get("name"))
