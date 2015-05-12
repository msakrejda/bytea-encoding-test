class ByteaThing < Sequel::Model
  plugin :timestamps

end

class NineOneByteaThing < Sequel::Model(:bytea_things)
  self.db = NINE_ONE_DB
  plugin :timestamps

end
