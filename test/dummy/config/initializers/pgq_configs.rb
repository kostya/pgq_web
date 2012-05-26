
class Consumer2 < Pgq::Consumer
  def self.database 
    Base2
  end
end
