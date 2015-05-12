class ByteaThing < Sequel::Model
  plugin :timestamps

  include AttrVault

  vault_keyring ENV['ATTR_VAULT_KEYRING']
  vault_attr :stuff
end

class NineOneByteaThing < Sequel::Model(:bytea_things)
  self.db = NINE_ONE_DB
  plugin :timestamps

  include AttrVault

  vault_keyring ENV['ATTR_VAULT_KEYRING']
  vault_attr :stuff
end
