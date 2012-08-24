require './database'

namespace :db do

  desc 'Run pending migration'
  task :migrate do
    DataMapper.auto_upgrade!
  end

end
