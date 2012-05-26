class CreateHistoryQueue < ActiveRecord::Migration
  def self.up
    Pgq::Consumer.add_queue :history
  end

  def self.down
    Pgq::Consumer.remove_queue :history
  end
end
