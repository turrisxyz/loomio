class CalendarEvent < ApplicationRecord
  def parsed
    Icalendar::Event.parse(self.ical).first
  end
end
