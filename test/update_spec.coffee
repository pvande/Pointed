vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer#update'

suite.addBatch
  "On a Pointer instance,":
    topic: -> { object: { a: { b: { c: 'string' } } }, key: 'value' }

    '#update replaces the pointer data with the returned data': (data) ->
      newData = { new: 'data' }

      ptr = Pointer(data)
      ptr.update(-> newData)

      assert.strictEqual(ptr.value(), newData)

    '#update changes object references back to the root': (data) ->
      ptr = Pointer(data)
      ptr.get('object', 'a', 'b', 'c').update(-> 'new string')

      assert.notStrictEqual(ptr.value(), data)

    '#update changes the underlying data': (data) ->
      ptr = Pointer(data)
      ptr.get('object', 'a', 'b', 'c').update(-> 'new string')

      assert.equal(ptr.value('object', 'a', 'b', 'c'), 'new string')

    '#update does not change object references for unaffected data': (data) ->
      ptr = Pointer(data)
      ptr.get('key').update(-> 'new value')

      assert.strictEqual(ptr.value('object'), data.object)

    '#update does not change object references for equivalent data': (data) ->
      ptr = Pointer(data)

      ptr.get('object', 'a', 'b', 'c').update (obj) -> 'string'
      assert.strictEqual(ptr.value('object'), data.object)

      ptr.get('object').update (obj) -> JSON.parse(JSON.stringify(obj))
      assert.strictEqual(ptr.value('object'), data.object)

suite.export(module)
