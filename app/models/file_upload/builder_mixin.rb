module FileUpload
  module BuilderMixin

    def file_upload(field, options = {}, &block)
      if options.delete(:multiple)
        @template.multiple_file_upload_field(@object_name, field, @object.send(field).to_a, options, &block)
      else
        @template.single_file_upload_field(@object_name, field, @object.send(field), options, &block)
      end
    end

  end
end