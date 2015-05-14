require 'json'

class ByteaThing < Sequel::Model
  plugin :timestamps

  include AttrVault

  vault_keyring ENV['ATTR_VAULT_KEYRING']
  vault_attr :stuff
end
