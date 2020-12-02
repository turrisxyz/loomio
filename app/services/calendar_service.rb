require 'icalendar/recurrence'
module CalendarService
  def self.import(file, user_id)
    calendars = Icalendar::Calendar.parse file
    calendars.each do |calendar|
      events = calendar.events.map do |event|
        CalendarEvent.new(
          uid: event.uid,
          user_id: user_id,
          dtstamp: event.dtstamp,
          created: event.created,
          last_modified: event.last_modified,
          sequence: event.sequence,
          summary: event.summary,
          description: event.description,
          location: event.location,
          status: event.status,
          transp: (event.transp == "TRANSPARENT"),
          ical: event.to_ical
        )
      end
      ids = CalendarEvent.import(events, on_duplicate_key_ignore: true).ids

      case calendar.ip_method
      when 'REQUEST', 'PUBLISH'
        max = 5.years.from_now
        CalendarEvent.where(id: ids).each do |calendar_event|
          if calendar_event.recurrence_id
            CalendarOccurrence.find_by(uid: calendar_event.uid,
                                       start_at: event.recurrence_id).
                               update(start_at: calendar_event.dtstart)
          else
            CalendarOccurrence.where(uid: calendar_event.uid).delete_all
            min = calendar_event.parsed.dtstart
            occurrences = calendar_event.parsed.occurrences_between(min, max).map do |o|
              CalendarOccurrence.new(start_at: o.start_time,
                                     end_at: o.end_time,
                                     uid: calendar_event.uid,
                                     calendar_event_id: calendar_event.id)
            end
            CalendarOccurrence.import(occurrences)
          end
        end
      when 'CANCEL'
        calendar.events.each do |event|
          # Time.zone.parse(event.recurrence_id.iso8601)
          CalendarOccurrence.where(uid: event.uid.to_s, start_at: event.recurrence_id).delete_all
        end
      else
        raise "unhandled calendar.ip_method"
      end
    end
  end
end
