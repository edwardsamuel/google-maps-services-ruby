# Changelog

## HEAD

* Using required positional and optional named parameters (_breaking changes_)
* Documentation with examples
* Documentation using markdown syntax
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