class Base2 < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "#{Rails.env || 'development'}2"
end
