window.analytics = {}
analyticsMethods = ['load', 'page', 'pageview', 'track', 'trackLink', 'identify']
analyticsMethods.forEach (method) -> analytics[method] = () ->

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

  it "should record virtual pageviews when we change pages", ->
    $rootScope.$emit "$routeChangeSuccess"
    expect(window.analytics.page).toHaveBeenCalled()

    $rootScope.$emit "$routeChangeSuccess"
    expect(window.analytics.page.callCount).toBe(2)


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

