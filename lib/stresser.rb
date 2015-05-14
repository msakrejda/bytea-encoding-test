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

    data = nil
    begin
      1000.times do
        data = Sequel.blob(rand.bytes(176))
        DB.execute(DB.fetch(<<-EOF, data: data).sql)
INSERT INTO bytea_things(data) VALUES(:data)
EOF
      end
    rescue StandardError => e
      puts <<-EOF
#{e.class}: #{e.message}
#{e.backtrace.join("\n")}
bogus value is:
  class: #{data.class}
  length: #{data.length}
  raw value: #{Base64.encode64(data)}
EOF
      raise
    end

    DB[:bytea_things].delete

    lock.synchronize { active = false }
  ensure
    sequel_thread.join unless sequel_thread.nil?
  end
end
