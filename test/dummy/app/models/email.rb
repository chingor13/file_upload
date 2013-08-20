class Email < ActiveRecord::Base

  has_many :attachments, class_name: DbFile, as: :owner

  validates :subject, presence: true
  validates :message, presence: true

  accepts_nested_attributes_for :attachments, allow_destroy: true

end