class AddCoordinatesToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
    add_column :posts, :address, :string
  end
end
