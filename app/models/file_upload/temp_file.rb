module FileUpload
  class TempFile
    attr_accessor :name, :content_type, :data, :size

    include FileUpload::RedisFileReadable

    def initialize(attributes = {})
      attributes.each do |k, v|
        self.send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    def persisted?
      false
    end
  end
end