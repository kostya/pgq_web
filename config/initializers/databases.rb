
class PgqWeb::Watcher
  class << self
    attr_accessor :databases
  end

  self.databases = [ ActiveRecord::Base ]
end
