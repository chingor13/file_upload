module FileUpload
  module RedisFileReadable
    extend ActiveSupport::Concern

    included do
      attr_reader :key
      attr_accessor :copy_from
    end

    def key=(key)
      @key = key
      if redis_file = RedisFile.find(key)
        self.data = redis_file.data
        self.name = redis_file.name
        self.content_type = redis_file.type
        self.size = redis_file.size
      end
    end

  end
end