require 'bundler'
Bundler.require
require_relative "../initializer"

task :stress do
  loop do
    begin
      Stresser.run_batch
    rescue StandardError => e
      Rollbar.error(e)
    end
    sleep 1
  end
end
