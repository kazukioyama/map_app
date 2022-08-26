class CreateLodgings < ActiveRecord::Migration[6.0]
  def change
    create_table :lodgings do |t|
      t.string :place_id
      t.decimal :lat, precision: 10, scale: 7
      t.decimal :lng, precision: 10, scale: 7
      t.string :name, null: false, default: ""
      t.string :reference
      t.text :types, array: true
      t.decimal :rating, precision: 2, scale: 1
      t.string :vicinity

      t.timestamps
    end
  end
end
