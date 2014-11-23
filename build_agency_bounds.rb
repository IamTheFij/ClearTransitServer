require './environments.rb'
require './models/active.rb'
require './lib/nextbus.rb'
require './lib/utils.rb'

agencies = {}

AgencyBound.all.each do |bound|
    bound.lat_min = nil
    bound.lat_max = nil
    bound.lon_min = nil
    bound.lon_max = nil
    agencies[bound.agency] = bound
end

NextBus.agency_list.parsed_response['agency'].each do |agency|
    unless agencies.has_key?(agency['tag'])
        agencies[agency['tag']] = AgencyBound.new(
            agency: agency['tag'],
            lat_min: nil,
            lat_max: nil,
            lon_min: nil,
            lon_max: nil
        )
    end
end

agencies.each_value do |bound|
    routes = NextBus.routes(bound.agency).parsed_response['route']
    print "#{routes}\n"
    unless routes.nil?
        unless routes.kind_of?(Array)
            routes = [ routes ]
        end
        routes.each do |route|
            route_config = NextBus.route_config(bound.agency, route['tag']).parsed_response
            #print "Route Config:\n#{route_config}\n"
            route_config = route_config['route']
            print "Agency: #{bound.agency} Route: #{route['tag']} Bound Min: #{bound.lat_min}, Config Min #{route_config['latMin']}\n"
            bound.lat_min = min_val(bound.lat_min, route_config['latMin'].to_f)
            bound.lat_max = max_val(bound.lat_max, route_config['latMax'].to_f)
            bound.lon_min = min_val(bound.lon_min, route_config['lonMin'].to_f)
            bound.lon_max = max_val(bound.lon_max, route_config['lonMax'].to_f)
        end
        bound.save
    end
end

