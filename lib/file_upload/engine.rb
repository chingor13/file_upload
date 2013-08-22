module FileUpload
  class Engine < ::Rails::Engine
    isolate_namespace FileUpload

    config.file_upload = ActiveSupport::OrderedOptions.new

    initializer "append migrations" do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] << File.join(root, "db/migrate")
      end
    end

    initializer "file_upload.assets.precompile" do |app|
      app.config.assets.precompile += %w(file_upload.js file_upload.css)
    end

    initializer "file_upload.set_config" do |app|
      redis_config = app.config.file_upload.redis || {
        host: "localhost",
        port: 6379,
        db: 7
      }

      FileUpload::Engine.config.redis = 
        case redis_config
        when Hash
          Redis.new(redis_config)
        else
          redis_config
        end
    end

    initializer "file_upload.helpers" do |app|
      ActiveSupport.on_load :action_controller do
        helper FileUpload::TagHelper
      end
    end

  end
end
