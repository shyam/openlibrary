require 'rubygems'
require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://root@localhost/openlibrary_dev')

Dir["./models/*.rb"].each { |model| require model }
DataMapper.finalize