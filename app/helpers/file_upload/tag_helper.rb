module FileUpload::TagHelper

  def file_upload_field(model_name, attribute_name, value, options = {}, &block)
    layout = options.delete(:multiple) ? "multiple" : "single"

    render(layout: "file_upload/tags/#{layout}", locals: {
      model_name: model_name,
      attribute_name: attribute_name,
      value: value,
      options: options
    }, &block)
  end

  def file_size(file)
    number_with_precision(file.size / 1024.0, precision: 2)
  end
  
end