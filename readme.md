"fricken lasers v1.0" by Mathew Emerson - 24/08/13

A small script that works out the optimal laser power required, the dB loss and the light reading at each end point for both 1310nm and 1550nm single mode optical fibre for the 'fricken laser beams' as per the Australian NBN standards.

* 0.35 dB loss per kilometre (1310nm SMOF)
* 0.21 dB loss per kilometre (1550nm SMOF)
* 0.10 dB loss per fusion splice
* 0.30 dB loss per connection
* 19.0 dB loss at 32 way splitter (ODF)

## Setup

1. Install bundler

````
gem install bundler
````

2. Bundle gems

````
bundle install
````

3. Run specs

`````
bundle exec rspec
`````

