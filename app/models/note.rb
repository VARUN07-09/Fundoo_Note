class Note < ApplicationRecord
  belongs_to :user
  # has_and_belongs_to_many :collaborators, class_name: 'User', join_table: 'collaborators_notes'

  validates :title, presence: true
end
