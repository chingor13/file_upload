module FileUpload
  class Engine < ::Rails::Engine
    isolate_namespace FileUpload

    initializer "append migrations" do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] << File.join(root, "db/migrate")
      end
    end

    initializer "file_upload.assets.precompile" do |app|
      app.config.assets.precompile += %w(upload.js upload.css)
    end

  end
end
