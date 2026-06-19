# Headless test runner.
#
#   godot --path . --headless --script tests/run_tests.gd
#
# Loads each script in TEST_SCRIPTS, runs every `test_*` method, and exits
# non-zero if any assertion failed. Test methods may be coroutines (await).
extends SceneTree

const TEST_SCRIPTS := [
  "res://tests/test_flatcv.gd",
  "res://tests/test_nodes.gd",
  "res://tests/test_graph.gd",
]


func _initialize() -> void:
  # Run once the main loop is iterating so coroutine tests can await frames.
  process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
  var total := 0
  var failed := 0

  for path in TEST_SCRIPTS:
    var script: GDScript = load(path)
    if script == null:
      push_error("Could not load test script: %s" % path)
      print("FAIL (load) %s" % path)
      failed += 1
      continue
    print("\n%s" % path.get_file())
    var instance = script.new()
    instance.tree = self

    var seen := {}
    for method in instance.get_method_list():
      var method_name: String = method.name
      if not method_name.begins_with("test_") or seen.has(method_name):
        continue
      seen[method_name] = true
      total += 1
      instance.reset()
      await instance.call(method_name)
      if instance.failures.is_empty():
        print("  PASS %s" % method_name)
      else:
        failed += 1
        print("  FAIL %s" % method_name)
        for f in instance.failures:
          print("       %s" % f)
  print("\n%d test(s), %d failed" % [total, failed])
  quit(1 if failed > 0 else 0)
