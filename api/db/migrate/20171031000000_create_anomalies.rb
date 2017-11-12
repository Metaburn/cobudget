class CreateAnomalies < ActiveRecord::Migration
  def change
    create_table :anomalies do |t|
      t.text :tablename
      t.jsonb :data
      t.text :reason
      t.text :who
      t.timestamps null: false
    end
  end
end
