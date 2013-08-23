require 'test_helper'

class RedisFileReadableTest < ActiveSupport::TestCase

  class TestFile
    attr_accessor :name, :content_type, :size, :data

    include FileUpload::RedisFileReadable
  end

  teardown do
    FileUpload::Engine.config.redis.flushdb
  end

  test "can load data from a key" do
    file = FileUpload::RedisFile.new({
      :file_io => Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/avatar.jpeg', __FILE__)),
    })
    assert file.save

    tf = TestFile.new
    tf.key = file.id

    assert_equal("image/jpeg", tf.content_type)
    assert_equal("avatar.jpeg", tf.name)
    assert(tf.size)
    assert(tf.data)
  end

end