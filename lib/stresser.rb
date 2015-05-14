require 'net/http'

class Stresser

  APP_NAME = 'secret-plains-3232'

  def self.random_letters
    2.times.map { SecureRandom.random_number(2**64).to_s(32) }.join('')
  end

  def self.random_url
    "postgres://#{random_letters}:#{random_letters}@example.com/#{random_letters}"
  end

  def self.run_batch
    lock = Mutex.new
    active = true
    http_thread = Thread.new do
      while lock.synchronize { active } do
        Net::HTTP.get('https://#{APP_NAME}.herokuapp.com/') rescue nil
        sleep 0.05
      end
    end

    rand = Random.new
    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      Thread.new do
        1000.times do
          klazz.create(data: Sequel.blob(rand.bytes(176)),
                       stuff: random_url)
        end
      end
    end.each(&:join)

    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      Thread.new do
        all_things = klazz.all
        1000.times do
          thing = all_things.sample
          thing.update(data: Sequel.blob(rand.bytes(176)),
                       stuff: random_url)
        end
      end
    end.each(&:join)

    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      klazz.dataset.delete
    end
    lock.synchronize { active = false }
    http_thread.join
  end
end
