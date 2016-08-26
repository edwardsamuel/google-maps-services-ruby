# Changelog

## 0.4.2

* Add nearest roads Google Roads API support

## 0.4.1

* Support JRuby 9.0.0.0
* Refactoring and more test coverage

## 0.4.0

* Use required positional and optional named parameters (_breaking changes_)
* Documentation with examples
* Documentation using markdown syntax
* Use OpenSSL instead Ruby-HMAC to sign url
* Customizeable HTTP client
* Fix QPS bug: ensure number of queue items is the given value

## 0.3.0

* QPS: Query per second
* Refactor lib

## 0.2.0

* Support Ruby >= 2.0.0
* Auto-retry connection when the request is failed and possible
* Restructure test (rspec) directory
* Refactor lib

## 0.1.0

* Initial release.
* Support Ruby >= 2.2
* [Google Maps Web Service API](https://developers.google.com/maps/documentation/webservices/) scope:
    - [Directions API](https://developers.google.com/maps/documentation/directions/)
    - [Distance Matrix API](https://developers.google.com/maps/documentation/distancematrix/)
    - [Elevation API](https://developers.google.com/maps/documentation/elevation/)
    - [Geocoding API](https://developers.google.com/maps/documentation/geocoding/)
    - [Time Zone API](https://developers.google.com/maps/documentation/timezone/)
    - [Roads API](https://developers.google.com/maps/documentation/roads/)