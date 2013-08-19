module FileUpload::Attachable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_many_s3_files(attr_name, default_attrs = {})
      default_attrs[:scope] = attr_name
      has_many attr_name, -> {where scope: attr_name}, class_name: "FileUpload::S3File", as: :owner, inverse_of: :owner
      accepts_nested_attributes_for attr_name
      define_method("#{attr_name}_attributes_with_defaults=") do |attrs|
        new_attrs = Array(attrs).map do |data|
          data.reverse_merge(default_attrs)
        end
        self.send("#{attr_name}_attributes_without_defaults=", new_attrs)
      end
      alias_method_chain :"#{attr_name}_attributes=", :defaults
      define_method("existing_#{attr_name}_attributes=") do |attrs|
        mapped_attrs = []
        attrs.each do |k, v|
          mapped_attrs << {
            "id" => k, 
            "_destroy" => v["_destroy"] || "1"
          }
        end
        self.send("#{attr_name}_attributes=", mapped_attrs)
      end
    end

    def has_one_s3_file(attr_name, default_attrs = {})
      default_attrs[:scope] = attr_name
      has_one attr_name, -> {where scope: attr_name}, class_name: "FileUpload::S3File", as: :owner, inverse_of: :owner
      define_method("#{attr_name}_attributes=") do |attrs|
        attrs = attrs.first if attrs.is_a?(Array)
        attrs = default_attrs.merge(attrs)
        if existing = self.send(attr_name)
          existing.update_attributes(attrs)
        else
          self.send("build_#{attr_name}", attrs)
        end
      end
    end
  end
end