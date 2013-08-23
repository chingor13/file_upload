module FileUpload
  class RedisFile
    extend ActiveModel::Naming

    # 1 hour
    FILE_EXPIRY = 60 * 60

    attr_accessor :file_io
    attr_writer :key, :name, :id

    def initialize(attrs = {})
      attrs.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    class << self

      def find_by_id(uuid)
        key = base_key(uuid)
        name, type, size = redis.mget(name_key(key), type_key(key), size_key(key))
        if name && type && size
          new({
            id:   uuid,
            key:  key,
            name: name,
            type: type,
            size: size
          })
        else
          nil
        end
      end

      def find(uuid)
        find_by_id(uuid) || raise(ActiveRecord::RecordNotFound)
      end

      def name_key(base_key)
        "#{base_key}:name"
      end

      def data_key(base_key)
        "#{base_key}:data"
      end

      def type_key(base_key)
        "#{base_key}:type"
      end

      def size_key(base_key)
        "#{base_key}:size"
      end

      def base_key(uuid)
        "redis_file:#{uuid}"
      end
    end

    def key
      @key ||= self.class.base_key(id)
    end

    def id
      @id ||= SecureRandom.random_number(1000000000)
    end

    def data_key
      self.class.data_key(key)
    end

    def name_key
      self.class.name_key(key)
    end

    def type_key
      self.class.type_key(key)
    end

    def size_key
      self.class.size_key(key)
    end

    def name
      @name ||= begin
        if file_io
          file_io.original_filename
        else
          nil
        end
      end
    end

    def data
      @data ||= begin
        if file_io
          file_io.read
        elsif key
          redis.get(data_key)
        end
      end
    end

    def data=(data)
      @data = data
    end

    def size
      @size ||= data.size
    end

    def type
      @type ||= FileMagic.new(FileMagic::MAGIC_MIME_TYPE).buffer(data)
    end

    def save
      redis.setex(data_key, FILE_EXPIRY, data)
      redis.setex(name_key, FILE_EXPIRY, name)
      redis.setex(type_key, FILE_EXPIRY, type)
      redis.setex(size_key, FILE_EXPIRY, size)
    end

    def destroy
      redis.del(data_key, name_key, type_key, size_key)
    end

    def to_json
      {
        size: size,
        name: name,
        type: type,
        id: id,
        key: key
      }
    end

    def to_key
      [key]
    end

    def to_param
      id.to_s
    end

    def persisted?
      redis.exists(data_key)
    end

    protected

    def redis
      self.class.redis
    end

    def self.redis
      @redis ||= FileUpload::Engine.config.redis
    end
  end
end