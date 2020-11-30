class AddCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_events do |t|
      t.integer  :user_id
      t.string   :uid
      t.datetime :start_at
      t.datetime :end_at
      t.integer  :sequence, default: 0, null: false
      t.string   :recurrence_id
      t.string   :rrule
      t.string   :exdate, array: true
      t.string   :rdate, array: true
      t.string   :summary
      t.string   :description
      t.string   :location
      t.string   :organizer
      t.string   :status
      t.boolean  :transp
    end

    create_table :calendar_occurences do |t|
      t.integer :calendar_event_id
      t.datetime :start_at
      t.datetime :end_at
    end

    add_index :calendar_events, :user_id
    add_index :calendar_events, [:uid, :sequence], unique: true
    add_index :calendar_events, :start_at
    add_index :calendar_events, :end_at
    add_index :calendar_occurances, :calendar_event_id
    add_index :calendar_occurances, :start_at
    add_index :calendar_occurances, :end_at
  end
end
