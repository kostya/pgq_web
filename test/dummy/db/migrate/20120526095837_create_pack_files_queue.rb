class CreatePackFilesQueue < ActiveRecord::Migration
  def self.up
    Pgq::Consumer.add_queue :pack_files
  end

  def self.down
    Pgq::Consumer.remove_queue :pack_files
  end
end
