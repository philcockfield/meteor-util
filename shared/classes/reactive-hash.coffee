###
A hash/dictionary that is reactive, but does not persist
values across hot-code-pushes.
###
class ReactiveHash
  ###
  Constructor.
  @param options:
            - onlyOnChange: The default [onlyOnChange] value.
  ###
  constructor: (options = {}) ->
    @keys = {}
    @_deps = {}
    @onlyOnChange = options.onlyOnChange ? false


  ###
  Disposes of the hash.
  ###
  dispose: ->
    @isDisposed = true
    @keys = {}
    @_deps = {}


  ###
  Default setting for the 'onlyOnChange' option passed to the [prop] method.
  ###
  onlyOnChange: false



  ###
  Gets the value at the given key.
  @param key: The unique identifier of the value (this is prefixed with the namespace).
  ###
  get: (key) =>
    return if @isDisposed
    @deps(key).depend()
    @keys[key]


  ###
  Sets the given value
  @param key:   The unique identifier of the value (this is prefixed with the namespace).
  @param value: The value to set (pass nothing/undefined to remove).
  @param options:
            onlyOnChange:  (optional). Will only call set if the value has changed.
                                           Default is set by the [defaultOnlySetIfChanged] property.
  ###
  set: (key, value, options = {}) =>
    return if @isDisposed

    # Don't set if the value hasn't changed (and this check is specified)
    onlyOnChange = if options.onlyOnChange? then options.onlyOnChange else @onlyOnChange
    if onlyOnChange and Object.equal(value, @keys[key])
      return value

    if value is undefined then delete @keys[key] else @keys[key] = value
    @deps(key).changed()

    value


  ###
  Removes the value with the given key.
  Same as calling 'set' with undefined.
  @param key:   The unique identifier of the value (this is prefixed with the namespace).
  ###
  unset: (key) => @set(key, undefined)


  ###
  Remove all values from the session object.
  ###
  clear: -> @unset(key) for key of @keys


  ###
  Gets the dependency object for the given key.
  ###
  deps: (key) ->
    @_deps[key] = new Deps.Dependency() unless @_deps[key]
    @_deps[key]



  ###
  Gets or sets the value for the given key.
  @param key:         The unique identifier of the value (this is prefixed with the namespace).
  @param value:       (optional). The value to set (pass null to remove).
  @param options:
            default:  (optional). The default value to return if the session does not contain the value (ie. undefined).
            onlyOnChange:  (optional). Will only call set if the value has changed.
                                           Default is set by the [defaultOnlySetIfChanged] property.
  ###
  prop: (key, value, options = {}) ->
    if value isnt undefined
      # WRITE.
      @set(key, value, options)
    else
      # READ ONLY.
      value = @get(key)
      value = options.default if value is undefined

    value



