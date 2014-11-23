require 'httparty'

class NextBus
    include HTTParty

    def self.get_command(command, query={})
        # Set the command
        query[:command] = command
        get('http://webservices.nextbus.com/service/publicJSONFeed', :query => query)
    end

    def self.agency_list
        get_command('agencyList')
    end

    def self.routes(agency)
        get_command('routeList', { :a => agency })
    end

    def self.route_config(agency, route)
        get_command('routeConfig', { :a => agency, :r => route })
    end

    def self.prediction(agency, route, stop, short_titles=true)
        get_command('predictions', { :a => agency, :r => route, :s => stop, :useShortTitles => short_titles })
    end

    def self.prediction_multiple(agency, route_stops=[])
        endpoint = 'http://webservices.nextbus.com/service/publicJSONFeed'
        endpoint += '?command=predictionsForMultiStops'
        endpoint += '&a=' + agency
        route_stops.each do |route_stop|
            endpoint += '&stops=' + route_stop[:route] + '%7C' + route_stop[:stop]
        end

        print endpoint

        get(endpoint)
    end

end
