(function() {
  var isExternalLink,
    __slice = [].slice;

  isExternalLink = function(url) {
    var a;
    a = document.createElement('a');
    a.href = url;
    return a.origin !== window.location.origin;
  };

  angular.module('fs-segmentio', []).factory('segmentio', function() {
    var methods;
    methods = {};
    ['load', 'page', 'pageview', 'track', 'trackLink', 'identify'].forEach(function(method) {
      return methods[method] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return window.analytics[method].apply(window.analytics, args);
      };
    });
    return methods;
  }).run([
    '$rootScope', 'segmentio', function($rootScope, segmentio) {
      return $rootScope.$on("$routeChangeSuccess", function() {
        return segmentio.page();
      });
    }
  ]).directive('track', [
    'segmentio', function(segmentio) {
      return {
        restrict: 'A',
        link: function($scope, $element, attributes) {
          var name, payload;
          name = attributes.track;
          payload = $scope.$eval(attributes.trackData);
          if (isExternalLink(attributes.href)) {
            return segmentio.trackLink($element[0], name, payload);
          } else {
            return $element.on('click', function(event) {
              return segmentio.track(name, payload);
            });
          }
        }
      };
    }
  ]);

}).call(this);
