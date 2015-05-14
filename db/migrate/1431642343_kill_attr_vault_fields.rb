Sequel.migration do
  up do
    alter_table(:bytea_things) do
      drop_column :key_id
      drop_column :stuff_encrypted
    end
  end
end
