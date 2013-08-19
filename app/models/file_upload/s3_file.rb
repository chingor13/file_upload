module FileUpload
  class S3File < ActiveRecord::Base
    belongs_to :owner, polymorphic: true, touch: true

    validates :owner, presence: true
    validates :name, presence: true
    validates :bucket, presence: true
    validates :path, presence: true
    validate :has_data_to_write, on: :create

    serialize :options, Hash

    before_validation :set_defaults
    before_validation :symbolize_option_keys

    around_save :persist_to_s3

    attr_reader :key, :s3_file

    def key=(key)
      @key = key
      if redis_file = RedisFile.find(key)
        self.data = redis_file.data
        self.name = redis_file.name
        self.content_type = redis_file.type
        self.size = redis_file.size
      end
    end

    def data=(new_data)
      @new_data = true
      @data = new_data
    end

    def data
      @data ||= begin
        s3_object.read
      rescue
        nil
      end
    end

    def s3_file=(file)
      @s3_file = file
      self.size = file.size
      self.content_type = file.content_type
      self.name = file.name
      self.bucket = file.bucket
      self.path = file.path
    end

    def s3_file_id=(file_id)
      self.s3_file = S3File.find(file_id)
    end

    # generate a readable url
    def url(secure = false, expiry = 600)
      if options[:acl] == :public_read
        scheme = secure ? "https" : "http"
        "#{scheme}://" + File.join(bucket, fullpath) rescue nil
      else
        # temporary access to S3 file
        s3_object.url_for(:read, expires: expiry, secure: secure).to_s
      end
    end

    protected

    def new_data?
      @new_data ? true : false
    end

    def write_to_s3!(io_or_data)
      blob = io_or_data.respond_to?(:read) ? io_or_data.read : io_or_data.to_s
      s3_object.write(blob, options)
    end

    def s3_object
      s3.buckets[bucket].objects[fullpath]
    end

    # programmatically generate the s3 path: [path]/[id]/[name]
    def fullpath
      File.join(path, id.to_s, name)
    end
    
    def old_s3_object
      old_path = File.join(path_was, id.to_s, name_was)
      s3.buckets[bucket_was].objects[old_path]
    end

    def s3
      @s3 ||= FileUpload::Engine.config.s3
    end

    def has_data_to_write
      if !data ||
         (data.respond_to?(:length) && data.length.zero?) ||
         (data.respond_to?(:size) && data.size.zero?)
        errors.add(:base, "Missing file data")
      end
    end

    def persist_to_s3
      path_changed = (changes.keys & ["name", "bucket", "path"]).present?
      was_new_record = new_record?

      yield

      if s3_file
        # copy from an existing file
        s3_file.s3_object.copy_to(s3_object)
      else
        if path_changed
          if new_data?
            # new_data
            old_s3_object.delete unless was_new_record
            write_to_s3!(data)
          else
            # copy the old object to the new location
            old_s3_object.move_to(s3_object, options)
          end
        elsif new_data?
          # same location, new data
          old_s3_object.delete unless was_new_record
          write_to_s3!(data)
        end
      end
      @new_data = false # don't write more that once
    end

    def set_defaults
      if self.path.respond_to?(:call)
        self.path = self.path.call(self)
      end

      if data.is_a?(ActionDispatch::Http::UploadedFile)
        self.name = data.original_filename
        self.content_type = data.content_type
        self.size = data.size
        self.options ||= {}
        self.options[:content_type] ||= data.content_type
      end
    end
    
    def symbolize_option_keys
      self.options ||= {}
      self.options = options.symbolize_keys
    end

  end
end
