vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer#get'

suite.addBatch
  "On a Pointer instance,":
    topic: ->
      obj = { object: { a: { b: { c: 'string' } } }, key: 'value' }
      ptr = Pointer(obj)
      { ptr, obj }

    '#get with no arguments returns a Pointer': ({ptr, obj}) ->
      assert.instanceOf(ptr.get(), Pointer)
    '#get with arguments returns a new Pointer': ({ptr, obj}) ->
      assert.instanceOf(ptr.get('object', 'a'), Pointer)
    '#get returns a Pointer to nested content': ({ptr, obj}) ->
      newPtr = ptr.get('object', 'a', 'b')
      assert.equal(newPtr.value('c'), obj.object.a.b.c)
    '#get with an array argument also works': ({ptr, obj}) ->
      newPtr = ptr.get(['object', 'a', 'b'])
      assert.equal(newPtr.value('c'), obj.object.a.b.c)

suite.export(module)
