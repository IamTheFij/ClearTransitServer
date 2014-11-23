# Table for storing boundries of given agencies to auto-detect
class AgencyBound < ActiveRecord::Base
    validates :agency, :lat_max, :lat_min, :lon_max, :lon_min, presence: true
    # validates :lat_max, presence: true
    # validates :lat_min, presence: true
    # validates :lon_max, presence: true
    # validates :lon_min, presence: true
end
