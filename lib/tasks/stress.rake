require 'bundler'
Bundler.require
require_relative "../initializer"

task :stress do
  Stresser.run
end
