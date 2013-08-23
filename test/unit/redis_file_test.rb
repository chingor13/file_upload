require 'test_helper'

class RedisFileTest < ActiveSupport::TestCase

  teardown do
    FileUpload::Engine.config.redis.flushdb
  end

  test "can preserve attributes" do

    tf = FileUpload::RedisFile.new({
      :file_io => Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/avatar.jpeg', __FILE__)),
    })
    assert_equal("image/jpeg", tf.type)
    assert(tf.save, "should be able to save the file to redis")

    tf2 = FileUpload::RedisFile.find(tf.id)
    assert_equal(tf.key, tf2.key)
    assert_equal("avatar.jpeg", tf2.name)
    assert_equal("image/jpeg", tf2.type)
  end

  test "can detect file type" do
    tf = FileUpload::RedisFile.new({
      :file_io => Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/test_upload.txt', __FILE__)),
    })
    assert_equal("text/plain", tf.type)
  end

end
