vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer#value'

suite.addBatch
  "On a Pointer instance,":
    topic: ->
      obj = { object: { a: { b: { c: 'string' } } }, key: 'value' }
      ptr = Pointer(obj)
      { ptr, obj }

    '#value with no arguments returns the object': ({ptr, obj}) ->
      assert.strictEqual(ptr.value(), obj)
    '#value with a known argument returns the property': ({ptr, obj}) ->
      assert.strictEqual(ptr.value('key'), obj.key)
    '#value with an unknown argument returns undefined': ({ptr, obj}) ->
      assert.strictEqual(ptr.value('nope'), obj.nope)
    '#value with multiple arguments performs a chained lookup': ({ptr, obj}) ->
      assert.strictEqual(ptr.value('object', 'a', 'b', 'c'), obj.object.a.b.c)

suite.export(module)
