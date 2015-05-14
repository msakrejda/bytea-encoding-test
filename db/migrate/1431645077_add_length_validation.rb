Sequel.migration do
  up do
    execute <<-EOF
ALTER TABLE bytea_things ADD CONSTRAINT valid_bytea_size
  CHECK (data IS NULL OR octet_length(data) = 176)
EOF
  end
end
