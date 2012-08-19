namespace :db do

  desc 'Run pending migration'
  task :migrate do
    require './database'
    DataMapper.auto_upgrade!
  end

  task :reset do
    require './database'
    DataMapper.auto_migrate!
  end

end
