require 'sinatra'
require 'sinatra/activerecord'
require 'json'

require './cleartransit.rb'
require './lib/nextbus.rb'

get '/' do
    # TODO: Provide link to download the app
    'Hello world! Go check out the repo: <a href="https://github.com/IamTheFij/CanHazMuni-Web">CanHazMuni-Web</a>'
end

get '/working' do
    'Hello world! Go check out the repo: <a href="https://github.com/IamTheFij/CanHazMuni-Web">CanHazMuni-Web</a>'
end

# List all agencies
get '/agency' do
    status 200
    body(NextBus.agency_list.to_json)
end

# List all routes in an agency
get '/agency/:agency/route' do |agency|
    status 200
    body(NextBus.routes(agency).to_json)
end

# List all stops in a route
get '/agency/:agency/route/:route/stop' do |agency, route|
    status 200
    body(NextBus.route_config(agency, route).to_json)
end

# Get predictions for a given stop
get '/agency/:agency/route/:route/stop/:stop' do |agency, route, stop|
    status 200
    body(NextBus.prediction(agency, route, stop).to_json)
end

# Get predictions for nearest stop on given agency and route
get '/agency/:agency/route/:route/nearest' do |agency, route|
    # will match /agency/sf-muni/route/F/nearest?lat=37.804016399999995&lon=-122.40376609999998
    lat = to_f_nil(params[:lat])
    lon = to_f_nil(params[:lon])
    if params[:lat].nil? or lon.nil? or route.nil?
        status 404
    else
        status 200
        body(get_nearest_predictions(agency, route, lat, lon).to_json)
    end
end

# Primary feature
# Usine Lat, Lon, determine nearest agency, and stops and provide predictions
=begin rdoc
get '/icanhaz' do
    # will match /icanhaz?lat=37.804016399999995&lon=-122.40376609999998&route=F%20line

    if params[:lat].nil? or params[:lon].nil? or params[:route].nil?
        status 404
    else
        status 200
        # TODO: Implement
        body({:thing1 => 'value'}.to_json)
    end
end
=end

# Usine Lat, Lon and given agency, and user route and provide predictions
get '/icanhaz/:agency' do |agency|
    # will match /icanhaz/sf-muni?lat=37.804016399999995&lon=-122.40376609999998&route=F%20line
    lat = to_f_nil(params[:lat])
    lon = to_f_nil(params[:lon])
    if agency.nil? or lat.nil? or lon.nil? or params[:route].nil?
        body("Error: Post convert agency: #{agency} lat: #{lat} lon: #{lon} route: #{params[:route]}")
        status 404
    else
        status 200

        # Use only the best route for now
        route = find_best_routes(agency, params[:route])[0]

        body(get_nearest_predictions(agency, route[:tag], params[:lat], params[:lon]).to_json)
    end
end

get '/icanhaz/agency/route' do
    # will match /icanhaz/agency/route?lat=37.804016399999995&lon=-122.40376609999998&route=F%20line
    lat = to_f_nil(params[:lat])
    lon = to_f_nil(params[:lon])
    if lat.nil? or lon.nil? or params[:route].nil?
        body("Error: Post convert lat: #{lat} lon: #{lon} route: #{params[:route]}")
        status 404
    else
        agencies = get_contained_agencies(lat, lon)

        if agencies.empty?
            # TODO: Find better status code for something like this
            status 404

            body("No service area found")
        else
            status 200

            agency = agencies[0]
            user_route = params[:route];

            # Get the most likely route in the  agency
            # TODO: Match all the results returned to the RouteMatch class and insert all.
            #       This will be super useful to provide a scroll list for the user to pick
            #       alternate matches. The client can then mark which was actually matched.
            #       When doing this, will probably want a unique "session" Id as well
            route_match = find_best_routes(agency, user_route)[0]
            route_match.save

            body(route_match.to_json)
        end
    end
end

# Usine given agency, and user route, guess the route
get '/icanhaz/:agency/route' do |agency|
    # will match /icanhaz/sf-muni/route?route=F%20line
    if agency.nil? or params[:route].nil?
        status 404
    else
        status 200

        user_route = params[:route];

        # Get the most likely route in the  agency
        # TODO: Match all the results returned to the RouteMatch class and insert all.
        #       This will be super useful to provide a scroll list for the user to pick
        #       alternate matches. The client can then mark which was actually matched.
        #       When doing this, will probably want a unique "session" Id as well
        route_match = find_best_routes(agency, user_route)[0]
        route_match.save

        body(route_match.to_json)
    end
end

# Usine given agency, and actual route, get the predictions
get '/icanhaz/:agency/route/:route' do |agency, route|
    # will match /icanhaz/sf-muni/route/F?lat=37.804016399999995&lon=-122.40376609999998
    # Optionally takes &match_id=123
    lat = to_f_nil(params[:lat])
    lon = to_f_nil(params[:lon])
    if agency.nil? or route.nil? or lat.nil? or lon.nil?
        body("Error: Post convert lat: #{lat} lon: #{lon} route: #{params[:route]}")
        status 404
    else
        status 200

        # Get Id of databse tracked route match and indicate that it was accepted for predictions
        if not params[:match_id].nil?
            RouteMatch.update(params[:match_id], :accepted => true)
        end

        body(get_nearest_predictions(agency, route, lat, lon).to_json)
    end
end

get '/route_matches' do
    status 200
    body(RouteMatch.all.to_json)
end
