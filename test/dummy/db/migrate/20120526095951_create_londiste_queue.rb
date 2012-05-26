class CreateLondisteQueue < ActiveRecord::Migration
  def self.up
    Consumer2.add_queue :londiste
  end

  def self.down
    Consumer2.remove_queue :londiste
  end
end
