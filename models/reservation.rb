class Reservation
  include DataMapper::Resource

  property :id, Serial, :required => true
  belongs_to :book, :required => true
  belongs_to :user, :required => true
  is :state_machine, :initial => :issued, :column => :state do
    state :issued
    state :returned

    event :forward do
      transition :from => :issued, :to => :returned
    end
  end
end