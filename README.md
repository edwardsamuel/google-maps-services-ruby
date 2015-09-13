# Ruby Client for Google Maps Services

*This is porting of [Python Client for Google Maps Services](https://github.com/googlemaps/google-maps-services-python). All Google Maps Service APIs are supported, but some features (e.g: auto retry) are not supported right now.*

## Description

Use Ruby? Want to [geocode][Geocoding API] something? Looking for [directions][Directions API]?
Maybe [matrices of directions][Distance Matrix API]? This library brings the [Google Maps API Web
Services] to your Ruby application.
![Analytics](https://ga-beacon.appspot.com/UA-66926725-1/google-maps-services-ruby/readme?pixel)

The Ruby Client for Google Maps Services is a Ruby Client library for the following Google Maps APIs:

 - [Directions API]
 - [Distance Matrix API]
 - [Elevation API]
 - [Geocoding API]
 - [Time Zone API]
 - [Roads API]

Keep in mind that the same [terms and conditions](https://developers.google.com/maps/terms) apply
to usage of the APIs when they're accessed through this library.

## Support

This library is community supported. We're comfortable enough with the stability and features of
the library that we want you to build real production applications on it. We will try to support,
through Stack Overflow, the public and protected surface of the library and maintain backwards
compatibility in the future; however, while the library is in version 0.x, we reserve the right
to make backwards-incompatible changes. If we do remove some functionality (typically because
better functionality exists or if the feature proved infeasible), our intention is to deprecate
and give developers a year to update their code.

If you find a bug, or have a feature suggestion, please [log an issue][issues]. If you'd like to
contribute, please read [How to Contribute](#contributing).

## Requirements

 - Ruby 2.0 or later.
 - A Google Maps API key.

### API keys

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

    $ gem install google_maps_service

## Developer Documentation

View the [reference documentation](http://www.rubydoc.info/gems/google_maps_service)

Additional documentation for the included web services is available at
https://developers.google.com/maps/.

 - [Directions API]
 - [Distance Matrix API]
 - [Elevation API]
 - [Geocoding API]
 - [Time Zone API]
 - [Roads API]

## Usage

This example uses the [Geocoding API].

```ruby
gmaps = GoogleMapsService::Client.new(key: 'Add Your Key here')

# Geocoding and address
geocode_result = gmaps.geocode(address: '1600 Amphitheatre Parkway, Mountain View, CA')

# Look up an address with reverse geocoding
reverse_geocode_result = gmaps.reverse_geocode(latlng: [40.714224, -73.961452])

# Request directions via public transit
now = Time.now
directions_result = gmaps.directions(origin: "Sydney Town Hall",
                                     destination: "Parramatta, NSW",
                                     mode: "transit",
                                     departure_time: now)
```

For more usage examples, check out [the tests](spec/).

## Contributing

1. Fork it ( https://github.com/edwardsamuel/google-maps-services-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[apikey]: https://developers.google.com/maps/faq#keysystem
[clientid]: https://developers.google.com/maps/documentation/business/webservices/auth

[Google Maps API Web Services]: https://developers.google.com/maps/documentation/webservices/
[Directions API]: https://developers.google.com/maps/documentation/directions/
[Distance Matrix API]: https://developers.google.com/maps/documentation/distancematrix/
[Elevation API]: https://developers.google.com/maps/documentation/elevation/
[Geocoding API]: https://developers.google.com/maps/documentation/geocoding/
[Time Zone API]: https://developers.google.com/maps/documentation/timezone/
[Roads API]: https://developers.google.com/maps/documentation/roads/

[issues]: https://github.com/googlemaps/google-maps-services-python/issues
