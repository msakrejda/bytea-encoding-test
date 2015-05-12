Sequel.migration do
  change do
    create_table(:bytea_things) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at
      bytea        :data
    end
  end
end
