require 'base64'

class Stresser

  APP_NAME = 'secret-plains-3232'

  def self.run
    loop do
      begin
        self.run_batch
      rescue StandardError => e
        puts "#{e.class}:#{e.message}\n#{e.backtrace.join("\n")}"
      rescue => e
        puts "unexpected error"
        puts "#{e.class}:#{e.message}\n#{e.backtrace.join("\n")}"
      else
        puts "batch completed"
      end
      sleep 1
    end
  end

  def self.random_letters
    2.times.map { SecureRandom.random_number(2**64).to_s(32) }.join('')
  end

  def self.random_url
    "postgres://#{random_letters}:#{random_letters}@example.com/#{random_letters}"
  end

  def self.test_bytea_encoding(db_url, len=32)
    Sequel.connect(db_url) do |c|
      actual = Sequel.blob(c.fetch("SELECT :bytes::bytea AS bytes",
                                   bytes: Sequel.blob(Random.new.bytes(len))).first[:bytes]).length
      if actual != len
        fail "Inconsistent bytea length: expected #{len}; got #{actual}"
      end
    end
  end

  def self.run_batch
    lock = Mutex.new
    active = true
    rand = Random.new
    sequel_thread = Thread.new do
      while lock.synchronize { active } do
        test_bytea_encoding(ENV['DATABASE_URL'])
      end
    end

    obj = nil
    begin
      1000.times do
        obj = ByteaThing.create
        obj.update(data: Sequel.blob(rand.bytes(176)),
                   stuff: nil)
      end
    rescue StandardError => e
      bogus_value = obj.values[:stuff_encrypted]
      puts <<-EOF
bogus value is:
  class: #{bogus_value.class}
  length: #{bogus_value.length}
  raw value: #{Base64.encode64(bogus_value)}
EOF
      raise
    end

    ByteaThing.dataset.delete

    lock.synchronize { active = false }
  ensure
    sequel_thread.join unless sequel_thread.nil?
  end
end
