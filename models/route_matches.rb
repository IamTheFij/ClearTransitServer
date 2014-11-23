# Table for storing the user input and levenshtein match
# Will be used to assess accuracy and user acceptance
class RouteMatch < ActiveRecord::Base
    validates :user_route, :match_route, :distance, presence: true
    # validates :match_route, presence: true
    # validates :distance, presence: true
    # TODO: Default value for accepted?
end

