isExternalLink = (url) ->
  a = document.createElement('a')
  a.href = url
  a.origin isnt window.location.origin

angular.module('fs-segmentio', [])
  .factory 'segmentio', ->
    methods = {}
    ['load', 'page', 'pageview', 'track', 'trackLink', 'identify'].forEach (method) ->
      methods[method] = (args...) ->
        window.analytics[method].apply(window.analytics, args)
    return methods

  .directive 'track', ['segmentio', (segmentio) ->
    restrict: 'A'
    link: ($scope, $element, attributes) ->
      name    = attributes.track
      payload = $scope.$eval(attributes.trackData)

      if isExternalLink(attributes.href)
        segmentio.trackLink($element[0], name, payload)
      else
        $element.on 'click', (event) -> segmentio.track(name, payload)
  ]
