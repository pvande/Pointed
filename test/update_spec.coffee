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

    '#update passes a copy of an object reference': (data) ->
      ptr = Pointer(data)

      original = ptr.value('object')
      ptr.get('object').update (obj) ->
        assert.notStrictEqual(obj, original)

        obj.d = true
        return original

      assert.deepEqual(Object.keys(ptr.value('object')), ['a'])

    '#update passes a copy of an array reference': (data) ->
      ptr = Pointer(array: [ 0 ])

      original = ptr.value('array')
      ptr.get('array').update (arr) ->
        assert.notStrictEqual(arr, original)

        arr.push(1, 2, 3)
        return original

      assert.deepEqual(ptr.value('array').length, 1)

    '#update passes null references through': (data) ->
      ptr = Pointer(null: null)

      original = ptr.value('null')
      ptr.get('null').update (x) -> 'not null'

      assert.equal(ptr.value('null'), 'not null')

    '#update passes undefined references through': (data) ->
      ptr = Pointer(undefined: undefined)

      original = ptr.value('undefined')
      ptr.get('undefined').update (x) -> 'not undefined'

      assert.equal(ptr.value('undefined'), 'not undefined')

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

suite.export(module)
