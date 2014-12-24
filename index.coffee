# Tests two given arguments for deep equality.
equal = (a, b) ->
  return true if a is b

  return false    unless typeof a is typeof b
  return (a is b) unless typeof a is "object"

  return false unless a.constructor is b.constructor

  if a instanceof Array
    return false unless a.length is b.length
    for _, i in a
      return false unless equal(a[i], b[i])

  else
    [aKeys, bKeys] = [Object.keys(a), Object.keys(b)]
    return false unless equal(aKeys.sort(), bKeys.sort())
    for key in aKeys
      return false unless equal(a[key], b[key])

  return true

# Creates a new object reference that is a shallow copy of the given object.
# TODO: This is too simplistic.
#   Known failures:
#   * new String("foo")
#   * new Constructor()
copy = (obj) ->
  return obj unless typeof obj is 'object'

  newObj = {}
  newObj[key] = value for own key, value of obj
  return newObj


class Pointer
  constructor: (obj) ->
    return new Pointer(obj) unless this instanceof Pointer
    @root = this
    @data = obj
    @path = []

    eventListeners = { 'swap': [] }
    getListenersFor = (key) ->
      key = [key] unless key instanceof Array
      unless key.every((k) -> typeof k is 'string')
        throw 'Must provide an event name!'

      eventListeners[key.join('\0\0')] ||= []

    # Adds an event listener for the given key.
    @on = (key, fn) ->
      throw 'Must provide a callback!' unless fn instanceof Function
      getListenersFor(key).push(fn)

    # Removes an event listener for the given key.
    @off = (key, fn) ->
      throw 'Must provide a callback!' unless fn instanceof Function
      listeners = getListenersFor(key)
      idx = listeners.indexOf(fn)
      listeners.splice(idx, 1) unless idx is -1

    # Invokes event callbacks for the given key.
    @emit = (key, data...) ->
      fn.apply(this, data) for fn in getListenersFor(key)
      return true

  # Returns a new Pointer as a reference into the wrapped object.
  get: (key...) ->
    key = key[0] if key.length is 1 && key[0] instanceof Array
    return this if key.length is 0
    return @root.get(@path.concat(key)) unless this is @root

    ptr = Object.create(Pointer.prototype)
    ptr.root = this
    ptr.path = key
    return ptr

  # Returns the value of this Pointer (if no key is supplied), or the value of
  # a named reference contained by this Pointer.
  value: (key...) ->
    lookup = (value, key) -> value[key] if value?
    @path.concat(key).reduce(lookup, @root.data)

  # Replaces the value of this pointer with the value returned by the given
  # function.
  update: (fn) ->
    value = @value()
    data = fn.call(this, copy(value))
    return if equal(data, value)

    if @path.length is 0
      @data = data
    else
      [parent..., key] = @path
      @root.get(parent).update (obj) -> (obj[key] = data; obj)

    @emit('swap', data, value)

  # Maps the given function over pointers to each element of the underlying
  # value.
  map: (fn = (x) -> x) ->
    value = @value()
    if value instanceof Array
      fn.call(this, @get(idx), idx) for _, idx in value
    else
      fn.call(this, @get(key), key) for own key of value

  # Basic EventEmitter behaviors; calls on subpointers are delegated to `@root`.
  on:   (event, args...) -> @root.on.call(this, [event, @path...], args...)
  off:  (event, args...) -> @root.off.call(this, [event, @path...], args...)
  emit: (event, args...) -> @root.emit.call(this, [event, @path...], args...)

module.exports = Pointer
