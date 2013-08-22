# FileUpload

A mountable Rails engine that abstracts temporary file storage for asynchronous file uploads.

## Motivation

File uploading is a common requirement for many applications. Why rewrite it from scratch for every project?

Enter `FileUpload`, a mountable Rails engine that handles uploading files asynchronously to temporary shared file storage (redis). Redis allows us to temporarily cache this file and gives us shared storage - we don't need to set up NFS or configure server affininty in order to preserve access to our temporary file.

## Usage

in your Gemfile:

```
gem 'file_upload'
```

in your routes.rb:

```
mount FileUpload::Engine => "/file_upload"
```

in your application.js (ensure it is loaded after jQuery):

```
//= require file_upload
```

in an initializer:

```
FileUpload::Engine.config.redis = Redis.new({
  host: "localhost",
  port: 6379,
  db: 7
})
```

in your form view:

```
<%= file_upload_field(:email, :attachments, email.attachments, multiple: true) do %>
  <%= link_to "add attachment", "#", class: "add" %>
<% end %>
```

## Configuration

The `file_upload_field` helper method renders 2 possible templates: 

* `file_upload/tags/single`	 - used for `has_one` associations
* `file_upload/tags/multiple` - used for `has_many` associations

In your main rails app, you can drop in templates in these paths and they will be found by the view resolver before the engine's built-in views.

## Dependencies

* `redis` - store expirable temp files in a shared place
* `ruby-filemagic` - magic mime-type detection (`file` unix command)
* jQuery - we use [jQuery FileUpload][jquery-file-upload] for the asynchronous file uploading

## Contributing

Please fork and send me a pull request.

## TODO

* Rails generator for installing views
* Allow you to configure the redis connection via environment config files
* Optional file system temp storage

## License

This project rocks and uses MIT-LICENSE.

[jquery-file-upload]: https://github.com/blueimp/jQuery-File-Upload