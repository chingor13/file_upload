# FileUpload

A mountable Rails engine that abstracts temporary file storage for asynchronous file uploads.

## Motivation

File uploading is a common requirement for many applications. Why rewrite it from scratch for every project?

Enter `FileUpload`, a mountable Rails engine that handles uploading files asynchronously to temporary shared file storage (redis). Redis allows us to temporarily cache this file and gives us shared storage - we don't need to set up NFS or configure server affininty in order to preserve access to our temporary file.

## Assumptions

* You want to asychronously upload files while the user completes a form
* You want to keep track of your uploaded files in an ActiveModel-like storage engine
* You are using rails
* You are using jQuery (or can use it)

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

in your form view:

```
<%= multiple_file_upload_field(:email, :attachments, email.attachments) do %>
  <%= link_to "add attachment", "#", class: "add" %>
<% end %>

<%= single_file_upload_field(:user, :avatar, user.avatar) do %>
  <%= link_to "add attachment", "#", class: "add" %>
<% end %>
```

## Configuration

### Models

`FileUpload` can handle both `has_one` and `has_many` associations.  We assume the parent model accepts nested attributes for the file model.

#### has_one

Let's say you want store a user's avatar image (has_one). Your model might look something like:

```
class User < ActiveRecord::Base
  has_one :avatar
  
  accepts_nested_attributes_for :avatar
end

class Avatar < ActiveRecord::Base
  belongs_to :user
  
  # should have accessors for data, name, content_type, and size
end
```

#### has_many

Let's say you want to store a bunch of attachments for an email (has_many). Your model might look something like:

```
class Email < ActiveRecord::Base
  has_many :attachments
	
  accepts_nested_attributes_for :attachments
end

class Attachment < ActiveRecord::Base
  belongs_to :email
  
  # should have accessors for data, name, content_type, and size
end
```

#### Reading from the temp file

`FileUpload` provides a nice mixin that makes it easy to load data from your tempfile.  Include `FileUpload::RedisFileReadable` into your file model and it will create an attribute writer `key=` that will load the temp file from redis into your file model.

```
class Avatar < ActiveRecord::Base
  …
  include FileUpload::RedisFileReadable
end
```

### Redis Connection

in your application.rb (or environments/*.rb):

```
# hash
config.file_upload.redis = {
  host: "redis1",
  port: 6379,
  db: 7
}

# connection
config.file_upload.redis = Redis.new({
  host: "redis1",
  port: 6379,
  db: 7
})
```

### Views

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
* Optional file system temp storage

## License

This project rocks and uses MIT-LICENSE.

[jquery-file-upload]: https://github.com/blueimp/jQuery-File-Upload