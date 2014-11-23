require 'sinatra'
#require 'sinatra/activerecord'
require 'json'
require 'geocoder'
require 'algorithms'
require 'levenshtein'

require './environments.rb'
require './models/active.rb'
require './lib/nextbus.rb'
require './lib/utils.rb'

# Uses bounds of the user and returns any agencies they are in the bounds of
def get_contained_agencies(lat, lon)
    agencies = []

    AgencyBound.all.each do |bound|
        if lat.between?(bound.lat_min, bound.lat_max) and lon.between?(bound.lon_min, bound.lon_max)
            agencies.push(bound.agency)
        end
    end

    return agencies
end

# Takes user input and agency and tries to find the most likely intended route
def find_best_routes(agency, user_route)

    # Remove Line from end of user_route
    user_route = user_route.downcase
    user_route_words = user_route.split
    if user_route_words.last == 'line'
        user_route_words.pop
    end
    user_route = user_route_words.join(' ')

    # TODO: Remove before Prod
    routes = NextBus.routes(agency).parsed_response
    #routes = {
    #    'route' => [
    #        {
    #            'title' => 'F - Market Warves',
    #            'tag' => 'F'
    #        },
    #        {
    #            'title' => 'P - ',
    #            'tag' => 'F'
    #        }
    #    ]
    #}

    probable_routes = Containers::MinHeap.new

    routes['route'].each do |route|
        dist = min_val(Levenshtein.distance(user_route, route['title'].downcase), Levenshtein.distance(user_route, route['tag'].downcase))
        route_match = RouteMatch.new(
            user_route: user_route,
            match_route: route['tag'],
            match_title: route['title'],
            agency: agency,
            # TODO: Depending on App implementation, default to false and set true or oposite
            accepted: false,
            distance: dist
        )
        probable_routes.push(dist, route_match)
    end

    routes = []
    while not probable_routes.empty? and routes.length < 10
        routes.push(probable_routes.pop)
    end

    return routes
end

# Takes an agency, route, and lat-lon and returns nearest predictions
def get_nearest_predictions(agency, route, lat, lon)
    current_location = [lat, lon]
    print current_location
    route_config = NextBus.route_config(agency, route).parsed_response

    min_stops = Containers::MinHeap.new

    route_config['route']['stop'].each do |stop|
        dist = Geocoder::Calculations.distance_between(current_location, [stop['lat'], stop['lon']])

        min_stops.push(dist, stop)
    end

    #stop_directions = build_direction_map(route_config)

    stops = [], route_stops = []

    while not min_stops.empty? and stops.length < 5
        stop = min_stops.pop
        # Build array out of the 5 closest stops
        stops.push(stop)
        # Push route stops for fetching predictions
        route_stops.push({:route => route, :stop => stop['tag']})
    end

    min_stops.clear

    prediction_multiple = NextBus.prediction_multiple(agency, route_stops).parsed_response

    # TODO: Possibly adjust sort order here if these appear to be wrong

    return prediction_multiple
end

def build_direction_map(route_config)
    # TODO: DEPRECIATE
    stop_directions = {}

    route_config['route']['direction'].each do |direction|
        direction['stop'].each do |stop|
            unless stop_directions[stop['tag']]
                stop_directions[stop['tag']] = []
            end
            stop_directions[stop['tag']].push(direction['name'])
        end
    end

    return stop_directions
end

