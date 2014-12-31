Pointed
=======

Pointed implements an intra-graph reference mechanism, similar to a functional
[zipper](https://www.haskell.org/haskellwiki/Zipper).  This library aims to be
as lightweight and comprehensible as possible, while still maintaining useful
performance and compatibility profiles.

``` coffeescript
  Pointer = require 'pointed'

  data = { nested: { data: 'structure' } }
  ptr = Pointer(data)

  subptr = ptr.get('nested', 'data')
  subptr.value()  # => 'structure'

  subptr = ptr.update (val) -> val.slice(0, 3)
  subptr.value()  # => 'str'
  ptr.value()  # => { nested: { data: 'str' } }
```

## Interface

### `Pointer(data)`
Returns a new Pointer instance for the root of the given `data` structure.

### `Pointer::get(key...)`
Returns a new Pointer instance for an element of the data structure represented
by the pointer.

### `Pointer::value(key...)`
Returns the underlying value for an element of the data structure represented by
the pointer.

### `Pointer::update((oldData) -> newData)`
Updates the data underlying the pointer based on the value returned by the given
function.  This will emit [a "swap" event](#Events) on this pointer and all
pointers that contain this one.

### `Pointer::map((ptr, key) -> obj)`
Iterates over the underlying array (or object), generating pointers for each
element, and passes each pointer and the index (or key) to the given function.
The values returned by the function will be collected and returned as an array.

### `Pointer::isEqual(otherPointer)`
Checks to see if this pointer and the given pointer both refer to the same path
and referenced equivalent data when they were created.

Note that two pointers that share the same underlying data and have the same
path will *always* return identical results, permitting pointers to be both
"long-lived" and always reflect current data.  It is for this reason that
"Pointer equality" takes creation time into account – path equality alone does
not answer the most common question, "Has this data changed?"

### `Pointer::hash`
A digest of the data represented by this hash.  Useful as a generic content key,
and for quickly testing data equality.

## Events

### `Pointer::on(event, fn)`
Adds a callback function for the named event to the pointer.

### `Pointer::off(event, fn)`
Removes a callback function for the named event to the pointer.

### `Pointer::emit(event, args...)`
Fires the named event for this pointer and other pointers to the same data,
passing the given arguments to the callback functions.

## Guarantees

* `Pointer#get` will always return a Pointer (possibly to an unknown property).
* `Pointer#value` will return `undefined` if the pointer cannot be resolved.
* Two pointers representing the same absolute path will return the same object.
* `Pointer#update` will not change object references if the data is unchanged.
  * Similarly, `Pointer#update` will not fire events if the data is unchanged.

## Notable Behavior

* Data that cannot be serialized to JSON is not currently supported.
* Events are always fired on a "fresh" pointer instance.  This makes it easy to
  compare "stale" pointers against a more current state.
* `Pointer#update` will *not* fire a 'swap' event for pointers to keys beneath
  it.  If this is behavior you need, it's recommended that you make smaller
  changes to more deeply nested pointers.

  ``` coffeescript
  P = Pointer({ a: { b: 1 } })
  A = P.get('a')
  AB = P.get('a', 'b')

  # This call will fire events on `P` and `A`, but not `AB`.
  A.update (obj) ->
    obj.b += 10
    return obj

  # This call will fire events on `P`, `A`, and `AB`.
  AB.update (value) -> value + 10
  ```

## Undefined Behavior

* Directly modifying the underlying data structure is not encouraged.
  * Use `Pointer#update` to make changes instead.

## TODO

* History
  * `undo`, `redo`
* `shouldComponentUpdate` Helpers
* Better Object cloning
