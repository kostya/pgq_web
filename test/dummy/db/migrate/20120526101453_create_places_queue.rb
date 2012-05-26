class CreatePlacesQueue < ActiveRecord::Migration
  def self.up
    Pgq::Consumer.add_queue :places
  end

  def self.down
    Pgq::Consumer.remove_queue :places
  end
end
