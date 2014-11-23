require 'cgi'
require 'uri'
require 'sinatra'
require 'sinatra/activerecord'

configure :development do
    set :database, 'sqlite:///dev.db'
    set :show_exceptions, true
end

configure :staging, :production do
    begin
        db = URI.parse(ENV["DATABASE_URL"])
    rescue URI::InvalidURIError
        raise "Invalid DATABASE_URL"
    end

    ActiveRecord::Base.establish_connection(
        :adapter    => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        :encoding   => 'unicode',
        :pool       => 5,
        :database   => db.path[1..-1],
        :username   => db.user,
        :password   => db.password,
        :host       => db.host,
        :port       => db.port
    )
end

