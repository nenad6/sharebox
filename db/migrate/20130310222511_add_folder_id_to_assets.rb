class AddFolderIdToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :folder_id, :integer
    add_index :assets, :folder_id
  end
end

