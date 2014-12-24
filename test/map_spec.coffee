vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer#map'

suite.addBatch
  "On a Pointer":
    topic: ->
      Pointer(object: { a: {1}, b: {2}, c: {3} }, array: [ {1}, {2}, {3} ])

    'to an object':
      topic: (ptr) ->
        ptr.get('object')

      '#map with no arguments returns an array of Pointers': (ptr) ->
        array = ptr.map()
        values = array.map (x) -> x.value()

        assert.instanceOf(ptr, Pointer) for ptr in array
        assert.deepEqual values, [{1}, {2}, {3}]

      '#map yields Pointers to the given function': (ptr) ->
        array = []
        ptr.map (x) -> array.push(x)
        values = array.map (x) -> x.value()

        assert.instanceOf(ptr, Pointer) for ptr in array
        assert.deepEqual array.map((x) -> x.value()), [{1}, {2}, {3}]

      '#map also yields array indices to the given function': (ptr) ->
        array = []
        ptr.map (_, idx) -> array.push(idx)

        assert.deepEqual array.sort(), ['a', 'b', 'c']

      '#map binds the given function to the pointer instance': (ptr) ->
        self = null
        ptr.map -> self = this

        assert.strictEqual self, ptr

    'to an array':
      topic: (ptr) ->
        ptr.get('array')

      '#map with no arguments returns an array of Pointers': (ptr) ->
        array = ptr.map()
        values = array.map (x) -> x.value()

        assert.instanceOf(ptr, Pointer) for ptr in array
        assert.deepEqual values, [{1}, {2}, {3}]

      '#map yields Pointers to the given function': (ptr) ->
        array = []
        ptr.map (x) -> array.push(x)
        values = array.map (x) -> x.value()

        assert.instanceOf(ptr, Pointer) for ptr in array
        assert.deepEqual array.map((x) -> x.value()), [{1}, {2}, {3}]

      '#map also yields array indices to the given function': (ptr) ->
        array = []
        ptr.map (_, idx) -> array.push(idx)

        assert.deepEqual array, [0, 1, 2]

      '#map binds the given function to the pointer instance': (ptr) ->
        self = null
        ptr.map -> self = this

        assert.strictEqual self, ptr

suite.export(module)
