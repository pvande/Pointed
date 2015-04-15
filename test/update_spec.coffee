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

    '#update fires a "swap" event on all affected nodes': (data) ->
      ptr = Pointer(data)

      [newResults, oldResults] = [[], []]
      appendData = (newData, oldData) ->
        newResults.push(newData)
        oldResults.push(oldData)

      ptr.on('swap', appendData)
      ptr.get('object').on('swap', appendData)
      ptr.get('object', 'a').on('swap', appendData)
      ptr.get('object', 'a', 'b').on('swap', appendData)
      ptr.get('object', 'a', 'b', 'c').on('swap', appendData)

      ptr.get('object', 'a', 'b', 'c').update -> 'new string'

      assert.deepEqual oldResults, [
        { key: 'value', object: { a: { b: { c: 'string' } } } }
        { a: { b: { c: 'string' } } }
        { b: { c: 'string' } }
        { c: 'string' }
        'string'
      ]

      assert.deepEqual newResults, [
        { key: 'value', object: { a: { b: { c: 'new string' } } } }
        { a: { b: { c: 'new string' } } }
        { b: { c: 'new string' } }
        { c: 'new string' }
        'new string'
      ]

    '#update does not fire a "swap" event if the data is unchanged': (data) ->
      ptr = Pointer(data)

      [newResults, oldResults] = [[], []]
      appendData = (newData, oldData) ->
        newResults.push(newData)
        oldResults.push(oldData)

      ptr.on('swap', appendData)
      ptr.get('object').on('swap', appendData)
      ptr.get('object', 'a').on('swap', appendData)
      ptr.get('object', 'a', 'b').on('swap', appendData)
      ptr.get('object', 'a', 'b', 'c').on('swap', appendData)

      ptr.get('object', 'a', 'b', 'c').update -> 'string'

      assert.deepEqual oldResults, []
      assert.deepEqual newResults, []

    '#update uses the same object type that is passed in': (data) ->
      data['array'] = [1,2,3,4,5]
      ptr = Pointer(data)

      ptr.get('object').update (target) ->
        assert.equal typeof target, 'object'
        assert.equal Array.isArray(target), false

      ptr.get('array').update (target) ->
        assert.equal Array.isArray(target), true

suite.export(module)
