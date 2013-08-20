class Email < ActiveRecord::Base

  has_many :attachments, class_name: DbFile, as: :owner

end