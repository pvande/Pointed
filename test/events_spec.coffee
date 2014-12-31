vows   = require 'vows'
assert = require 'assert'

Pointer = require '../'

suite = vows.describe 'Pointer Events'

suite.addBatch
  "On a top-level Pointer instance,":
    topic: ->
      Pointer(object: { a: { b: { c: 'string' } } }, key: 'value')

    'the #on method':
      'raises an exception when invoked without a callback': (ptr) ->
        assert.throws -> ptr.on('emit')

      'raises an exception when invoked without an event name': (ptr) ->
        assert.throws -> ptr.on(-> 'callback')

      'enables event subscription on the pointer, fired by #emit': (ptr) ->
        called = false
        ptr.on('!', -> called = true)
        ptr.emit('!')

        assert.isTrue(called)

      'permits multiple subscribers': (ptr) ->
        called = 0
        ptr.on('!', -> called += 1)
        ptr.on('!', -> called += 2)
        ptr.on('!', -> called += 4)
        ptr.emit('!')

        assert.equal(called, 7)

    'the #off method':
      'raises an exception when invoked without a callback': (ptr) ->
        assert.throws -> ptr.off('emit')

      'raises an exception when invoked without an event name': (ptr) ->
        assert.throws -> ptr.off(-> 'callback')

      'removes event subscription from the pointer': (ptr) ->
        called = false
        ptr.on('!', fn = (-> called = true))
        ptr.off('!', fn)
        ptr.emit('!')

        assert.isFalse(called)

      'removes individual subscribers': (ptr) ->
        called = 0
        ptr.on('!', fn1 = (-> called += 1))
        ptr.on('!', fn2 = (-> called += 2))
        ptr.on('!', fn4 = (-> called += 4))
        ptr.off('!', fn2)
        ptr.emit('!')

        assert.equal(called, 5)

    'the #emit method':
      'raises an exception when invoked without an event name': (ptr) ->
        assert.throws -> ptr.emit({ foo: 1 })

      'passes data through to the callback': (ptr) ->
        args = null
        ptr.on('!', -> args = [arguments...])
        ptr.emit('!', 1, 2, 3, 4, 5)

        assert.deepEqual(args, [1, 2, 3, 4, 5])

  "On a nested Pointer instance, ":
    topic: ->
      ptr = Pointer(object: { a: { b: { c: 'string' } } }, key: 'value')
      sub = ptr.get('object')
      { ptr, sub }

    'the #on method':
      'raises an exception when invoked without a callback': ({sub}) ->
        assert.throws -> sub.on('emit')

      'raises an exception when invoked without an event name': ({sub}) ->
        assert.throws -> sub.on(-> 'callback')

      'enables event subscription on the nested pointer': ({sub}) ->
        called = false
        sub.on('!', -> called = true)
        sub.emit('!')

        assert.isTrue(called)

      'permits multiple subscribers': ({sub}) ->
        called = 0
        sub.on('!', -> called += 1)
        sub.on('!', -> called += 2)
        sub.on('!', -> called += 4)
        sub.emit('!')

        assert.equal(called, 7)

      'is not called when the parent pointer fires events': ({ptr, sub}) ->
        called = false
        sub.on('!', -> called = true)
        ptr.emit('!')

        assert.isFalse(called)

    'the #off method':
      'raises an exception when invoked without a callback': ({sub}) ->
        assert.throws -> sub.off('emit')

      'raises an exception when invoked without an event name': ({sub}) ->
        assert.throws -> sub.off(-> 'callback')

      'removes event subscription from the pointer': ({sub}) ->
        called = false
        sub.on('!', fn = (-> called = true))
        sub.off('!', fn)
        sub.emit('!')

        assert.isFalse(called)

      'removes individual subscribers': ({sub}) ->
        called = 0
        sub.on('!', fn1 = (-> called += 1))
        sub.on('!', fn2 = (-> called += 2))
        sub.on('!', fn4 = (-> called += 4))
        sub.off('!', fn2)
        sub.emit('!')

        assert.equal(called, 5)

      'does not remove subscribers from the parent pointer': ({ptr, sub}) ->
        called = false
        ptr.on('!', fn = (-> called = true))
        sub.off('!', fn)
        ptr.emit('!')

        assert.isTrue(called)

    'the #emit method':
      'raises an exception when invoked without an event name': ({sub}) ->
        assert.throws -> sub.emit({ foo: 1 })

      'passes data through to the callback': ({sub}) ->
        args = null
        sub.on('!', -> args = [arguments...])
        sub.emit('!', 1, 2, 3, 4, 5)

        assert.deepEqual(args, [1, 2, 3, 4, 5])

      'invokes callbacks for all pointers to the given reference': ({ptr}) ->
        called = 0
        ptr.get('object').on('!', -> called += 1)
        ptr.get('object').on('!', -> called += 2)
        ptr.get('object').on('!', -> called += 4)
        ptr.get('object').emit('!')

        assert.equal(called, 7)

suite.export(module)
