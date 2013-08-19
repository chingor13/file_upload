class CreateFileUploadS3Files < ActiveRecord::Migration
  def change
    create_table :file_upload_s3_files do |t|
      t.string   "owner_type",   null: false
      t.integer  "owner_id",     null: false
      t.string   "name",         null: false
      t.string   "bucket",       null: false
      t.string   "path",         null: false
      t.integer  "size",         null: false
      t.string   "content_type", null: false
      t.string   "scope",        null: false
      t.text     "options"
      t.timestamps
    end
  end
end
