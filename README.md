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
Returns a new Pointer instance for an element of the  data structure represented
by the pointer.

### `Pointer::value(key...)`
Returns the underlying value for an element of the data structure represented by
the pointer.

### `Pointer::update((oldData) -> newData)`
Updates the data underlying the pointer based on the value returned by the given
function.

## Guarantees

* `Pointer#get` will always return a Pointer (possibly to an unknown property).
* `Pointer#value` will return `undefined` if the pointer cannot be resolved.
* Two pointers representing the same absolute path will return the same object.

## Undefined Behavior

* Directly modifying the underlying data structure is not encouraged.
  * Use the `Pointer#update` method to make changes instead.

## TODO

* Events
  * `on`, `once`, `off`, `emit`
* History
  * `undo`, `redo`
* `shouldComponentUpdate` Helpers
* Better Object cloning
