class InitialDb < ActiveRecord::Migration
  def up
      create_table :route_matches do |t|
          t.string      :user_route
          t.string      :match_route
          t.string      :match_title
          t.integer     :distance
          t.string      :agency
          t.boolean     :accepted
          t.timestamps
      end

      create_table :agency_bounds do |t|
          t.string  :agency
          t.float   :lat_max
          t.float   :lat_min
          t.float   :lon_max
          t.float   :lon_min
          t.timestamps
      end
  end

  def down
      drop_table :route_matches
      drop_table :agency_bounds
  end
end
