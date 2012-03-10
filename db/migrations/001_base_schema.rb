Sequel.migration do
  up do
    # Create books table
    create_table(:books) do
      primary_key :id
      String :isbn
      String :title
      String :publisher
      Integer :year
    end
  end
  down do
    # Drop the books table
    drop_table(:books)
  end
end