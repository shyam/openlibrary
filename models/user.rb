class User
  include DataMapper::Resource

  property :id, Serial
  property :employee_id, Integer
  property :ad_name, String, :index => true
  property :first_name, String
  property :last_name, String
end