module FileUpload::TagHelper

  def file_upload_field(model_name, attribute_name, value, options = {}, &block)
    render(layout: "file_upload/tags/field", locals: {
      model_name: model_name,
      attribute_name: attribute_name,
      value: value,
      file_url: file_upload.bulk_redis_files_path,
      options: options
    }, &block)
  end
  
end