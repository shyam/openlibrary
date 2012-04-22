class User
  include DataMapper::Resource

  property :id, Serial, :required => true
  property :employee_id, Integer, :required => true
  property :ad_name, String, :index => true, :required => true
  property :first_name, String, :required => true
  property :last_name, String, :required => true
end