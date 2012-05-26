class CreateIssuesQueue < ActiveRecord::Migration
  def self.up
    Consumer2.add_queue :issues
  end

  def self.down
    Consumer2.remove_queue :issues
  end
end
