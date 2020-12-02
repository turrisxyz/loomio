class AddCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_events do |t|
      t.integer  :user_id
      t.string   :uid
      t.string   :dtstart
      t.string   :dtend
      t.datetime :dtstamp
      t.datetime :created
      t.datetime :last_modified
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
      t.string   :ical
    end

    add_index :calendar_events, :user_id
    add_index :calendar_events, :uid
    add_index :calendar_events, :sequence

    create_table :calendar_occurrences do |t|
      t.integer :calendar_event_id
      t.string   :uid
      t.datetime :start_at
      t.datetime :end_at
    end

    add_index :calendar_occurrences, :calendar_event_id
    add_index :calendar_occurrences, :uid
    add_index :calendar_occurrences, :start_at
    add_index :calendar_occurrences, :end_at
  end
end
