noop = () ->

window.analytics =
  options: {}
  Integrations: {}
  _integrations: {}
  _readied: true
  _timeout: 300
  _user: {}
  log: noop
  addEventListener: noop
  on: noop
  once: noop
  removeEventListener: noop
  removeAllListeners: noop
  removeListener: noop
  off: noop
  emit: noop
  listeners: noop
  hasListeners: noop
  use: noop
  addIntegration: noop
  initialize: noop
  init: noop
  setAnonymousId: noop
  add: noop
  identify: noop
  user: noop
  group: noop
  track: noop
  trackLink: noop
  trackClick: noop
  trackForm: noop
  trackSubmit: noop
  page: noop
  pageview: noop
  alias: noop
  ready: noop
  timeout: noop
  debug: noop
  _options: noop
  _callback: noop
  _invoke: noop
  push: noop
  reset: noop
  _parseQuery: noop
  normalize: noop
  noConflict: noop
  _callbacks: {}
  require: noop
  VERSION: 1000
  initialized: true

analyticsMethods = Object.keys(window.analytics).filter (key) ->
  typeof window.analytics[key] is 'function'

describe 'The segmentio service', ->
  segmentio = undefined
  $location = undefined
  $rootScope = undefined

  inputs = [
    ['a', 'b', 'c']
    ['a']
    [1, 2, 3]
    ['tacos']
  ]

  spies =
    setup: -> analyticsMethods.forEach (func) -> spyOn(window.analytics, func)
    reset: -> analyticsMethods.forEach (func) -> window.analytics[func].reset()

  beforeEach () ->
    module('fs-segmentio')
    spies.setup()
    inject (_segmentio_, _$location_, _$rootScope_) ->
      segmentio = _segmentio_
      $location = _$location_
      $rootScope = _$rootScope_

  afterEach ->
    spies.reset()

  it "should proxy methods to the underlying library", ->
    test = (func, input) ->
      segmentio[func].apply(segmentio, input)
      expect(window.analytics[func]).toHaveBeenCalled()
      expect(window.analytics[func].argsForCall[0]).toEqual(input)

    analyticsMethods.forEach (func) ->
      inputs.forEach (input) ->
        test(func, input)
        spies.reset()

  it "should have a reset method", ->
    expect(typeof segmentio.reset).toBe('function')  


describe 'The segmentio directive', ->
  factory = undefined

  beforeEach ->
    module('fs-segmentio')

    factory = (type, event, data, link) ->
      el = undefined

      inject ($rootScope, $q, $compile) ->
        $rootScope.data = data if data

        if link
          tmpl = "<a href='#{link}' track='#{event}' #{if data then "track-data='data'" else ''}></a>"
        else
          tmpl = "<div track='#{event}' #{if data then "track-data='data'" else ''}></div>"

        el = angular.element(tmpl)
        $compile(el)($rootScope)
        $rootScope.$digest()
      return el

  it "should track events on click", ->
    spyOn(window.analytics, 'track')
    spyOn(window.analytics, 'trackLink')
    data = {tacos: 'tasty'}
    el = factory('event', 'foo', data)

    el.triggerHandler('click')

    expect(window.analytics.track).toHaveBeenCalledWith('foo', data)
    expect(window.analytics.trackLink).not.toHaveBeenCalled()


  it "should track events on internal links without delay", ->
    spyOn(window.analytics, 'track')
    spyOn(window.analytics, 'trackLink')
    data = {tacos: 'tasty'}
    el = factory('event', 'foo', data, window.location.origin + '/creators/')

    el.triggerHandler('click')

    expect(window.analytics.track).toHaveBeenCalledWith('foo', data)
    expect(window.analytics.trackLink).not.toHaveBeenCalled()


  it "should track events on external links with a delay", ->
    spyOn(window.analytics, 'track')
    spyOn(window.analytics, 'trackLink')
    data = {tacos: 'tasty'}
    el = factory('event', 'foo', data, 'http://google.com')

    el.triggerHandler('click')

    expect(window.analytics.trackLink).toHaveBeenCalledWith(el[0], 'foo', data)
    expect(window.analytics.track).not.toHaveBeenCalled()

