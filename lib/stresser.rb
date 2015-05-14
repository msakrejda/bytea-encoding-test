require 'net/http'

class Stresser

  APP_NAME = 'secret-plains-3232'

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
        test_bytea_encoding(ENV['NINE_ONE_DATABASE_URL'])
      end
    end

    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      Thread.new do
        1000.times do
          klazz.create(data: Sequel.blob(rand.bytes(176)),
                       stuff: random_url)
        end
      end
    end.each(&:join)

    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      klazz.dataset.delete
    end
    lock.synchronize { active = false }
  ensure
    sequel_thread.join unless sequel_thread.nil?
  end
end
