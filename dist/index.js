(function() {
  var isExternalLink, isFunc,
    slice = [].slice;

  isExternalLink = function(url) {
    var a;
    a = document.createElement('a');
    a.href = url;
    return a.origin !== window.location.origin;
  };

  isFunc = function(name) {
    return typeof window.analytics[name] === 'function';
  };

  angular.module('fs-segmentio', []).factory('segmentio', function() {
    var methods;
    methods = {};
    Object.keys(window.analytics).filter(isFunc).forEach(function(method) {
      return methods[method] = function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return window.analytics[method].apply(window.analytics, args);
      };
    });
    return methods;
  }).directive('track', [
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
