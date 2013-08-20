class User < ActiveRecord::Base

  has_one :avatar, class_name: DbFile, as: :owner

  validates :name, presence: true
  validates :avatar, presence: true

  accepts_nested_attributes_for :avatar

end