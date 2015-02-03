# fs-segmentio

`fs-segmentio` is a set of services and directives for integrating [analytics.js](https://segment.com/docs/libraries/analytics.js/)
from [SegmentIO](https://segment.com/) into an Angular application

## Installation

In your Angular project, run `bower install --save fs-segmentio` to save the module.
Then, in your HTML, add the script tags for `fs-segmentio` and `analytics.js`, dropping
in your Segment IO write key:

``` html
<script type="text/javascript">
  !function(){var analytics=window.analytics=window.analytics||[];if(!analytics.initialize)if(analytics.invoked)window.console&&console.error&&console.error("Segment snippet included twice.");else{analytics.invoked=!0;analytics.methods=["trackSubmit","trackClick","trackLink","trackForm","pageview","identify","group","track","ready","alias","page","once","off","on"];analytics.factory=function(t){return function(){var e=Array.prototype.slice.call(arguments);e.unshift(t);analytics.push(e);return analytics}};for(var t=0;t<analytics.methods.length;t++){var e=analytics.methods[t];analytics[e]=analytics.factory(e)}analytics.load=function(t){var e=document.createElement("script");e.type="text/javascript";e.async=!0;e.src=("https:"===document.location.protocol?"https://":"http://")+"cdn.segment.com/analytics.js/v1/"+t+"/analytics.min.js";var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(e,n)};analytics.SNIPPET_VERSION="3.0.1";
    analytics.load("<%= $YOUR_KEY_HERE %>");
  }}();
</script>
<script src="/path/to/bower_components/fs-segmentio/dist/index.min.js"></script>
```

And lastly, in your Angular module, include `fs-segmentio` as a dependency:

``` javascript
angular.module('my-app', ['fs-segmentio'])
```

## Usage

All methods on analytics.js are proxied, and exposed on a `segmentio`
service:

``` javascript
angular.module('my-app').run(function(segmentio) {
  segmentio.identify(my.user) // Identify a user
  segmentio.page() // Track a page event
})
```

Additionally, there's a `track` directive which will track events every time
the element is clicked:

``` html
  <a href='http://google.com' track='Clicked Google link'>To Google!</a>"
```

Under the hood, this is the same as calling `segmentio.track('Clicked Google link')`,
and the directive is smart enough to call `trackLink` on external links.

Data can be added to an event by adding a `track-data` attribute on the element:

``` html
  <a href='http://google.com'
    track='Clicked Google link'
    track-data="{userId: 'foo'}"
  >
    To Google!
  </a>"
```

Lastly, a `segmentio.page()` call is made everytime the core Angular router
emits a `$routeChangeSuccess` event, so your virtual Angular pages will trigger
pageviews normally.

## Contributing

To get your dev environment up and running, run `npm install` and `bower install`
to get the components we need.

Tests are run with `npm run test` against the minified source (to catch
Angular annotation errors). You can build the minified file as you work by
running `npm run build:watch`

Releases are built using `npm run release:[type]`. So, to generate a new patch
release, run `npm run release:patch`. This script will:

* Generate minified, concatenated JS files,
* Increment the version in `bower.json`
* Tag a new release

