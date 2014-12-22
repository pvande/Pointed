vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer'

suite.addBatch
  "When invoking with `new`":
    topic: -> new Pointer({})
    'a new instance of Pointer is returned': (ptr) ->
      assert.instanceOf(ptr, Pointer)

  "When invoking without `new`":
    topic: -> Pointer({})
    'a new instance of Pointer is returned': (ptr) ->
      assert.instanceOf(ptr, Pointer)

suite.export(module)
