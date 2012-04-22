require 'rubygems'
require 'data_mapper'
require 'dm-is-state_machine'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://root@localhost/openlibrary_dev')

Dir["./models/*.rb"].each { |model| require model }
DataMapper.finalize