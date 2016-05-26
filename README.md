# Ruby gem for Google Maps APIs

[![Gem Version](https://badge.fury.io/rb/google_maps_service.svg)](http://badge.fury.io/rb/google_maps_service) [![Build Status](https://travis-ci.org/edwardsamuel/google-maps-services-ruby.svg?branch=master)](https://travis-ci.org/edwardsamuel/google-maps-services-ruby) [![Dependency Status](https://gemnasium.com/edwardsamuel/google-maps-services-ruby.svg)](https://gemnasium.com/edwardsamuel/google-maps-services-ruby) [![Code Climate](https://codeclimate.com/github/edwardsamuel/google-maps-services-ruby/badges/gpa.svg)](https://codeclimate.com/github/edwardsamuel/google-maps-services-ruby) [![Coverage Status](https://coveralls.io/repos/edwardsamuel/google-maps-services-ruby/badge.svg?branch=master&service=github)](https://coveralls.io/github/edwardsamuel/google-maps-services-ruby?branch=master) [![Inch CI](https://inch-ci.org/github/edwardsamuel/google-maps-services-ruby.svg?branch=master)](https://inch-ci.org/github/edwardsamuel/google-maps-services-ruby?branch=master)

![Analytics](https://ga-beacon.appspot.com/UA-66926725-1/google-maps-services-ruby/readme?pixel)

*This gem is ported from [Python Client for Google Maps Services](https://github.com/googlemaps/google-maps-services-python).*

## Description

Use Ruby? Want to [geocode][Geocoding API] something? Looking for [directions][Directions API]?
Maybe [matrices of directions][Distance Matrix API]? This gem brings the [Google Maps API Web
Services] to your Ruby application.

The Ruby gem for Google Maps Web Service APIs is a gem for the following Google Maps APIs:

 - [Google Maps Directions API][Directions API]
 - [Google Maps Distance Matrix API][Distance Matrix API]
 - [Google Maps Elevation API][Elevation API]
 - [Google Maps Geocoding API][Geocoding API]
 - [Google Maps Time Zone API][Time Zone API]
 - [Google Maps Roads API][Roads API]

Keep in mind that the same [terms and conditions](https://developers.google.com/maps/terms) apply
to usage of the APIs when they're accessed through this gem.


## Features

### Rate Limiting

Never sleep between requests again! By default, requests are sent at the expected rate limits for
each web service, typically 10 queries per second for free users. If you want to speed up or slowdown requests, you can do that too, using `queries_per_second` options while initializing API client.

### Retry on Failure

Automatically retry when intermittent failures occur. That is, when any of the retriable 5xx errors
are returned from the API.

### Keys *and* Client IDs

Maps API for Work customers can use their [client ID and secret][clientid] to authenticate. Free
customers can use their [API key][apikey], too.

Note: Currently, [Roads API] does not accept client ID. It requires API key to authenticate the request.

### Ruby Hash/Array as API Result

This gem return a Ruby Hash/Array object as the API result. The result format structure is same as in Google Maps API documentation.

## Requirements

 - Ruby 2.0 or later.
 - A Google Maps API credentials (API keys or client IDs)

### Obtain API keys

Each Google Maps Web Service requires an API key or Client ID. API keys are
freely available with a Google Account at https://developers.google.com/console.
To generate a server key for your project:

 1. Visit https://developers.google.com/console and log in with
    a Google Account.
 1. Select an existing project, or create a new project.
 1. Click **Enable an API**.
 1. Browse for the API, and set its status to "On". The Python Client for Google Maps Services
    accesses the following APIs:
    * Directions API
    * Distance Matrix API
    * Elevation API
    * Geocoding API
    * Time Zone API
    * Roads API
 1. Once you've enabled the APIs, click **Credentials** from the left navigation of the Developer
    Console.
 1. In the "Public API access", click **Create new Key**.
 1. Choose **Server Key**.
 1. If you'd like to restrict requests to a specific IP address, do so now.
 1. Click **Create**.

Your API key should be 40 characters long, and begin with `AIza`.

**Important:** This key should be kept secret on your server.

## Installation

Add this line to your application's Gemfile:

    gem 'google_maps_service'

And then execute:

    bundle install

Or install it yourself as:

    gem install google_maps_service

In your Ruby code, add this line to load this gem:

    require 'google_maps_service'

## Usage

Before you request Google Maps API, you must configure the client.

You can view the [reference documentation](http://www.rubydoc.info/gems/google_maps_service).

### Configure client

```ruby
require 'google_maps_service'

# Setup API keys
gmaps = GoogleMapsService::Client.new(key: 'Add your key here')

# Setup client IDs
gmaps = GoogleMapsService::Client.new(
    client_id: 'Add your client id here',
    client_secret: 'Add your client secret here'
)

# More complex setup
gmaps = GoogleMapsService::Client.new(
    key: 'Add your key here',
    retry_timeout: 20,      # Timeout for retrying failed request
    queries_per_second: 10  # Limit total request per second
)
```
You can also set up the client globally.

```ruby
require 'google_maps_service'

# Setup global parameters
GoogleMapsService.configure do |config|
  config.key = 'Add your key here'
  config.retry_timeout = 20
  config.queries_per_second = 10
end

# Initialize client using global parameters
gmaps = GoogleMapsService::Client.new
```

For more examples and detail (setup **proxy**, **timeout**, **caching**, etc.) while initializing the client, check out [Client documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/Client#initialize-instance_method).

### Latitude/longitude pairs format

Some APIs require latitude/longitude pair(s) as their parameter(s). This gem accept various format of latitude/longitude pairs:

```ruby
# Array
latlng = [40.714224, -73.961452]

# Hash with symbolized keys
latlng = {lat: 40.714224, lng: -73.961452}
latlng = {latitude: 40.714224, longitude: -73.961452}

# Hash with string keys
latlng = {'lat' => 40.714224, 'lng' => -73.961452}
latlng = {'latitude' => 40.714224, 'longitude' => -73.961452}
```

### Directions API

```ruby
# Simple directions
routes = gmaps.directions(
    '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA',
    '2400 Amphitheatre Parkway, Mountain View, CA 94043, USA',
    mode: 'walking',
    alternatives: false)
```

Sample result:

```ruby
[{
  :bounds=>{
    :northeast=>{:lat=>37.4238004, :lng=>-122.084314},
    :southwest=>{:lat=>37.42277989999999, :lng=>-122.0882019}
  },
  :copyrights=>"Map data ©2015 Google",
  :legs=>[
    {
      :distance=>{:text=>"0.2 mi", :value=>393},
      :duration=>{:text=>"5 mins", :value=>287},
      :end_address=>"2400 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
      :end_location=>{:lat=>37.4238004, :lng=>-122.0882019},
      :start_address=>"1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
      :start_location=>{:lat=>37.42277989999999, :lng=>-122.084314},
      :steps=>[
        {
          :distance=>{:text=>"223 ft", :value=>68},
          :duration=>{:text=>"1 min", :value=>49},
          :end_location=>{:lat=>37.4228653, :lng=>-122.0850785},
          :html_instructions=>"Head <b>west</b>",
          :polyline=>{:points=>"kclcF|qchVEdAGx@ALAJ"},
          :start_location=>{:lat=>37.42277989999999, :lng=>-122.084314},
          :travel_mode=>"WALKING"
        }, {
          :distance=>{:text=>"108 ft", :value=>33},
          :duration=>{:text=>"1 min", :value=>23},
          :end_location=>{:lat=>37.423161, :lng=>-122.0850102},
          :html_instructions=>"Turn <b>right</b> toward <b>Amphitheatre Pkwy</b>",
          :maneuver=>"turn-right",
          :polyline=>{:points=>"}clcFvvchVg@IQC"},
          :start_location=>{:lat=>37.4228653, :lng=>-122.0850785},
          :travel_mode=>"WALKING"
        }, {
          :distance=>{:text=>"407 ft", :value=>124},
          :duration=>{:text=>"2 mins", :value=>90},
          :end_location=>{:lat=>37.423396, :lng=>-122.0863768},
          :html_instructions=>"Turn <b>left</b> onto <b>Amphitheatre Pkwy</b>",
          :maneuver=>"turn-left",
          :polyline=>{:points=>"welcFhvchVEf@Eb@C\\EZGp@Il@CRAJAJ"},
          :start_location=>{:lat=>37.423161, :lng=>-122.0850102},
          :travel_mode=>"WALKING"
        }, {
          :distance=>{:text=>"0.1 mi", :value=>168},
          :duration=>{:text=>"2 mins", :value=>125},
          :end_location=>{:lat=>37.4238004, :lng=>-122.0882019},
          :html_instructions=>
            "Slight <b>right</b> to stay on <b>Amphitheatre Pkwy</b><div style=\"font-size:0.9em\">Destination will be on the right</div>",
          :maneuver=>"turn-slight-right",
          :polyline=>{:points=>"gglcFz~chVGJADAD?DIh@MhAWhBOxACT"},
          :start_location=>{:lat=>37.423396, :lng=>-122.0863768},
          :travel_mode=>"WALKING"
        }
      ],
      :via_waypoint=>[]
    }
  ],
  :overview_polyline=>{:points=>"kclcF|qchVQxCy@MKjA[xCE^IVMz@y@bH"},
  :summary=>"Amphitheatre Pkwy",
  :warnings=>["Walking directions are in beta.    Use caution – This route may be missing sidewalks or pedestrian paths."],
  :waypoint_order=>[]
}]
```

For more usage examples and result format, check out [gem documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/Directions), [test script](https://github.com/edwardsamuel/google-maps-services-ruby/tree/master/spec/google_maps_service/apis/directions_spec.rb), and [Google Maps Directions API documentation][Directions API].

### Distance Matrix API

```ruby
# Multiple parameters distance matrix
origins = ["Bobcaygeon ON", [41.43206, -81.38992]]
destinations = [[43.012486, -83.6964149], {lat: 42.8863855, lng: -78.8781627}]
matrix = gmaps.distance_matrix(origins, destinations,
    mode: 'driving',
    language: 'en-AU',
    avoid: 'tolls',
    units: 'imperial')
```

For more usage examples and result format, check out [gem documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/DistanceMatrix), [test script](https://github.com/edwardsamuel/google-maps-services-ruby/tree/master/spec/google_maps_service/apis/distance_matrix_spec.rb), and [Google Maps Distance Matrix API documentation][Distance Matrix API].

### Elevation API

```ruby
# Elevation of some locations
locations = [[40.714728, -73.998672], [-34.397, 150.644]]
results = gmaps.elevation(locations)

# Elevation along path
locations = [[40.714728, -73.998672], [-34.397, 150.644]]
results = gmaps.elevation_along_path(locations, 5)
```

For more usage examples and result format, check out [gem documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/Elevation), [test script](https://github.com/edwardsamuel/google-maps-services-ruby/tree/master/spec/google_maps_service/apis/elevation_spec.rb), and [Google Maps Elevation API documentation][Elevation API].

### Geocoding API

```ruby
# Geocoding an address
results = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')

# Look up an address with reverse geocoding
results = gmaps.reverse_geocode([40.714224, -73.961452])
```

For more usage examples and result format, check out [gem documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/Geocoding), [test script](https://github.com/edwardsamuel/google-maps-services-ruby/tree/master/spec/google_maps_service/apis/geocoding_spec.rb), and [Google Maps Geocoding API documentation][Geocoding API].

### Roads API

```ruby
# Snap to roads
path = [
    [-33.8671, 151.20714],
    [-33.86708, 151.20683000000002],
    [-33.867070000000005, 151.20674000000002],
    [-33.86703, 151.20625]
]
results = gmaps.snap_to_roads(path, interpolate: true)

# Snapped speed limits
path = [
    [-33.8671, 151.20714],
    [-33.86708, 151.20683000000002],
    [-33.867070000000005, 151.20674000000002],
    [-33.86703, 151.20625]
]
results = gmaps.snapped_speed_limits(path)

# Speed limits
place_ids = [
  'ChIJ0wawjUCuEmsRgfqC5Wd9ARM',
  'ChIJ6cs2kkCuEmsRUfqC5Wd9ARM'
]
results = gmaps.speed_limits(place_ids)
```

For more usage examples and result format, check out [gem documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/Roads), [test script](https://github.com/edwardsamuel/google-maps-services-ruby/tree/master/spec/google_maps_service/apis/roads_spec.rb), and [Google Maps Roads API documentation][Roads API].

### Time Zone API

```ruby
# Current time zone
timezone = gmaps.timezone([39.603481, -119.682251])

# Time zone at certain time
timezone = gmaps.timezone([39.603481, -119.682251], timestamp: Time.at(1608))
```

For more usage examples and result format, check out [gem documentation](http://www.rubydoc.info/gems/google_maps_service/GoogleMapsService/Apis/TimeZone), [test script](https://github.com/edwardsamuel/google-maps-services-ruby/tree/master/spec/google_maps_service/apis/time_zone_spec.rb), and [Google Maps Time Zone API documentation][Time Zone API].

### Polyline encoder/decoder

[Google Encoded Polyline] is a lossy compression algorithm that allows you to store a series of coordinates as a single string. This format is used in some APIs:

  - [Directions API] encodes the result path.
  - [Elevation API] also accepts the encoded polyline as request parameter.

To handle Google Encoded Polyline, this gem provides encoder/decoder:

```ruby
require 'google_maps_service/polyline' # Or, require 'google_maps_service' is enough

# Decode polyline
encoded_path = '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
path = GoogleMapsService::Polyline.decode(encoded_path)
#=> [{:lat=>38.5, :lng=>-120.2}, {:lat=>40.7, :lng=>-120.95}, {:lat=>43.252, :lng=>-126.45300000000002}]

# Encode polyline
path = [[38.5, -120.2], [40.7, -120.95], [43.252, -126.453]]
encoded_path = GoogleMapsService::Polyline.encode(path)
#=> "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
```

## Issues and feature suggestions

If you find a bug, or have a feature suggestion, please [log an issue][issues]. If you'd like to
contribute, please read [How to Contribute](#contributing).

## Contributing

1. Fork it (https://github.com/edwardsamuel/google-maps-services-ruby/fork).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request.

[apikey]: https://developers.google.com/maps/faq#keysystem
[clientid]: https://developers.google.com/maps/documentation/business/webservices/auth

[Google Maps API Web Services]: https://developers.google.com/maps/web-services/overview/
[Directions API]: https://developers.google.com/maps/documentation/directions/
[Distance Matrix API]: https://developers.google.com/maps/documentation/distancematrix/
[Elevation API]: https://developers.google.com/maps/documentation/elevation/
[Geocoding API]: https://developers.google.com/maps/documentation/geocoding/
[Time Zone API]: https://developers.google.com/maps/documentation/timezone/
[Roads API]: https://developers.google.com/maps/documentation/roads/

[Google Encoded Polyline]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm

[issues]: https://github.com/edwardsamuel/google-maps-services-ruby/issues
