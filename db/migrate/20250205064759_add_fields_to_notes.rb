class AddFieldsToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :archived, :boolean
    add_column :notes, :trashed, :boolean
    add_column :notes, :color, :string
  end
end
