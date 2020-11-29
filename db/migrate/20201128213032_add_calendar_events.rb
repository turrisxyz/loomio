class AddCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_events do |t|
      t.integer :user_id
      t.string  :uid
      t.string  :title
      t.datetime :start_at
      t.datetime :end_at
    end

    add_index :calendar_events, :user_id
    add_index :calendar_events, :uid, unique: true
    add_index :calendar_events, :start_at
    add_index :calendar_events, :end_at
  end
end
