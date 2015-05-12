class ByteaThing < Sequel::Model
  plugin :timestamps

end

class NineOneByteaThing < Sequel::Model
  self.db = NINE_ONE_DB
  plugin :timestamps

end
