module Survivable
  def survivable(&block)
    begin
      yield
    rescue Exception => ex
    end
  end
end

RWorld(Survivable)
