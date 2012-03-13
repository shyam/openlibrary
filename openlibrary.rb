require "sinatra"
require "sequel"

DB = Sequel.connect('sqlite://db/ol.db')
set :views, Proc.new { File.join(root, "views") }

get "/" do
  erb :index
end

# show the reserve.erb; scan the isbn, reserve the book against a name.
get "/reserve" do
	erb :reserve
end

# calls the list.erb; lists down who has what and option to renew and return
get "/list" do
	erb :list
end

# backend ajax handler which returns the book info, reservation info., etc
post "/backend" do

end
