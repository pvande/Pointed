# Creates a hash representation of the given object, particularly useful for
# equality checks.
hash = (obj, seen = []) ->
  charCodes = JSON.stringify([obj]).split('').map (x) -> x.charCodeAt(0)
  code = charCodes.reduce ((a,x) -> ((a << 5) - a) + x | 0), 0
  return (Math.pow(2, 32) + code).toString(16).slice(-8)

# Creates a new object reference that is a shallow copy of the given object.
copy = (obj) ->
  return obj unless obj? and typeof obj is 'object'
  return [obj...] if obj instanceof Array
  return new Date(obj) if obj instanceof Date

  return extend(Object.create(obj.constructor.prototype), obj)

# Copies `extras` properties onto the given object.
extend = (obj, extras) ->
  obj[key] = value for own key, value of extras
  return obj

# Our atomic data container class.  The `root` property of every `Pointer`
# instance inherits from this, and new `Pointer` instances are created through
# this class.  All data manipulation and event operations on `Pointer`s are
# proxied through this class.
class Root
  constructor: (data) ->
    events = { 'swap': [] }
    @listeners = (key) ->
      throw 'Must provide an event name!' unless typeof key[0] is 'string'
      events[JSON.stringify(key)] ||= []

    @swap(data)

  # Creates a new `Pointer` instance for the given path.
  get: (path) ->
    extend new Pointer(this), path: path, hash: hash(@value(path))

  # Fetches the value at the given path.
  value: (path) ->
    path.reduce(((value, key) -> value[key] if value?), @data)

  # Atomically update the underlying data store.
  swap: (@data) ->

  # Adds an event listener for the given key.
  on: (key, fn) ->
    throw 'Must provide a callback!' unless fn instanceof Function
    @listeners(key).push(fn)

  # Removes an event listener for the given key.
  off: (key, fn) ->
    throw 'Must provide a callback!' unless fn instanceof Function
    listeners = @listeners(key)
    idx = listeners.indexOf(fn)
    listeners.splice(idx, 1) unless idx is -1

  # Invokes event callbacks for the given key.
  emit: (key, data...) ->
    ptr = @get(key.slice(1))
    fn.apply(ptr, data) for fn in @listeners(key)
    return


class Pointer
  constructor: (obj) ->
    if this instanceof Pointer && obj instanceof Root
      @root = obj
    else
      return (new Root(obj)).get([])

  # Returns a new Pointer as a reference into the wrapped object.
  get: (keys...) ->
    keys = keys[0] if keys.length is 1 && keys[0] instanceof Array
    @root.get(@path.concat(keys))

  # Returns the value of this Pointer (if no key is supplied), or the value of
  # a named reference contained by this Pointer.
  value: (keys...) ->
    keys = keys[0] if keys.length is 1 && keys[0] instanceof Array
    @root.value(@path.concat(keys))

  # Replaces the value of this pointer with the value returned by the given
  # function.
  update: (fn) ->
    value = @value()
    data = fn.call(this, copy(value))
    newHash = hash(data)
    return if @hash is newHash

    [parent..., key] = @path

    if key?
      @root.get(parent).update (obj) -> (obj[key] = data; obj)
    else
      @root.swap(data)

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
  on:   (event, args...) -> @root.on([event, @path...], args...)
  off:  (event, args...) -> @root.off([event, @path...], args...)
  emit: (event, args...) -> @root.emit([event, @path...], args...)

  # Computes pointer equality, based on hash identity.
  isEqual: (other) ->
    hash(@path) is hash(other.path) && @hash == other.hash

if module?
  module.exports = Pointer
else
  @Pointer = Pointer
