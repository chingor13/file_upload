class User < ActiveRecord::Base

  # fake nested attributes
  attr_accessor :avatar_attributes

end