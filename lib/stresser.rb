class Stresser
  def self.run_batch
    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      Thread.new do
        1000.times do
          klazz.create(data: Sequel.blob(Random.bytes(176)))
        end
      end
    end.each(&:join)

    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      Thread.new do
        all_things = klazz.all
        1000.times do
          thing = all_things.sample
          thing.update(data: Sequel.blob(Random.bytes(176)))
        end
      end
    end.each(&:join)

    [ ByteaThing, NineOneByteaThing ].map do |klazz|
      klazz.delete
    end    
  end
end
