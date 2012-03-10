desc "default: list tasks"
task :default do
  sh "rake -T"
end

desc "run forward migrations"
task :migrate do
  sh "sequel -m db/migrations sqlite://db/ol.db"
end

