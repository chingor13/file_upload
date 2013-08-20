class DbFile < ActiveRecord::Base

  belongs_to :owner, polymorphic: true

  include FileUpload::RedisFileReadable

  def url
    return "/db_files/#{id}/#{name}" if id
    return "/redis_files/#{key}/preview" if key
    nil
  end

end