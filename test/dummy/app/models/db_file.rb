class DbFile < ActiveRecord::Base

  belongs_to :owner, polymorphic: true

  include FileUpload::RedisFileReadable

  def url
    "SOMEURL"
  end

end