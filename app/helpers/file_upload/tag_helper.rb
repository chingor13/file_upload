module FileUpload
  module TagHelper
    def multiple_file_upload_field(model_name, attribute_name, value, options = {}, &block)
      render(layout: "file_upload/tags/multiple", locals: {
        model_name: model_name,
        attribute_name: attribute_name,
        value: value,
        options: options
      }, &block)
    end

    def single_file_upload_field(model_name, attribute_name, value, options = {}, &block)
      render(layout: "file_upload/tags/single", locals: {
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
end