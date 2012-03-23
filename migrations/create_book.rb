migration 1, :create_book do
  up do
    create_table :books do
      column :id,   Integer, :serial => true
      column :isbn, String
      column :title, String
      column :author, String
      column :photo_remote_url, String
    end
  end

  down do
    drop_table :books
  end
end