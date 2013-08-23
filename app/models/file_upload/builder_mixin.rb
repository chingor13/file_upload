module FileUpload
  module BuilderMixin

    def multiple_file_upload(field, options = {}, &block)
      @template.multiple_file_upload_field(@object_name, field, @object.send(field).to_a, options, &block)
    end

    def single_file_upload(field, options = {}, &block)
      @template.single_file_upload_field(@object_name, field, @object.send(field), options, &block)
    end

  end
end