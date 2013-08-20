class User < ActiveRecord::Base

  has_one :avatar, class_name: DbFile, as: :owner

  validates :name, presence: true

  accepts_nested_attributes_for :avatar, allow_destroy: true

end