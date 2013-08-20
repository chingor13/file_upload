class AddUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
    end

    create_table :emails do |t|
      t.string :subject
      t.string :message
    end

    create_table :db_files do |t|
      t.string :owner_type
      t.string :owner_id
      t.string :name
      t.integer :size
      t.string :content_type
      t.binary :data, limit: 10.megabyte
    end
  end
end
