class User < ActiveRecord::Base

  has_one :avatar, class_name: DbFile, as: :owner

end