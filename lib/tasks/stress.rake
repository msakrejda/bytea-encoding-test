require 'bundler'
Bundler.require
require_relative "../initializer"

task :stress do
  loop do
    begin
      Stresser.run_batch
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
