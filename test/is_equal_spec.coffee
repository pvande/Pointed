vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer#isEqual'

suite.addBatch
  "On a Pointer instance,":
    topic: ->
      obj = { nested: { key1: { a: 'string' }, key2: { a: 'string' } } }
      Pointer(obj)

    'two pointers with the same path and data are equal': (ptr) ->
      ptr1 = ptr.get('nested', 'key1')
      ptr2 = ptr.get('nested', 'key1')

      assert.isTrue(ptr1.isEqual(ptr2))

    'two pointers with different paths are not equal': (ptr) ->
      ptr1 = ptr.get('nested', 'key1')
      ptr2 = ptr.get('nested', 'key2')

      assert.isFalse(ptr1.isEqual(ptr2))

    'two pointers built against different data are not equal': (ptr) ->
      ptr1 = ptr.get('nested', 'key1')
      ptr2 = Pointer(ptr.value()).get('nested', 'key1')

      assert.isFalse(ptr1.isEqual(ptr2))

suite.export(module)
