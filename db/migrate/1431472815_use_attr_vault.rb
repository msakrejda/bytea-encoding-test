Sequel.migration do
  change do
    alter_table(:bytea_things) do
      add_column :key_id, :uuid
      add_column :stuff_encrypted, :bytea
    end
  end
end
