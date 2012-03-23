require 'dm-migrations'

namespace :db do

  desc 'Run pending migration'
  task :migrate do
    require 'dm-migrations/migration_runner'
    Dir["./migrations/*.rb"].each { |migration| require migration }
    DataMapper.auto_migrate!
  end
  
end