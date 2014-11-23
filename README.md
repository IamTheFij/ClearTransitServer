Clear Transit Server
====================

What is this?
-------------
This is a server component of Clear Transit. An Android and Google Glass application for retrieving transit times from the NextBus Api

The Android client for this Heroku app is located at [Clear Transit](https://github.com/IamTheFij/ClearTransit")

I'm really not much of a Ruby dev, so this may be a little hacky. It's designed to run on Heroku using a Postgres DB. 
The initial database is built by running: `ruby ./build_agency_bounds.rb` or, if it fails midway, running `ruby ./continue_agency_bounds.rb`. 

Heroku button
-------------
This buttons should install the server on Heroku. Should... no promises.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/IamTheFij/ClearTransitServer)

