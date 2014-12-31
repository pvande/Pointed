vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer'

suite.addBatch
  "When invoking":
    topic: -> Pointer({})
    'a new instance of Pointer is returned': (ptr) ->
      assert.instanceOf(ptr, Pointer)

suite.export(module)
