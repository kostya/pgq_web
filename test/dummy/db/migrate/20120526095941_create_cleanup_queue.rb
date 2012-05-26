class CreateCleanupQueue < ActiveRecord::Migration
  def self.up
    Pgq::Consumer.add_queue :cleanup
  end

  def self.down
    Pgq::Consumer.remove_queue :cleanup
  end
end
