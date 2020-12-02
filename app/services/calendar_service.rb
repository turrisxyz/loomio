require 'icalendar/recurrence'
module CalendarService
  def self.import(file, user_id)
    events = Icalendar::Event.parse(file).map do |event|
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

    max = 5.years.from_now
    CalendarEvent.where(id: ids).each do |calendar_event|
      CalendarOccurrence.where(calendar_event_id: calendar_event.id).delete_all
      min = calendar_event.parsed.dtstart
      occurrences = calendar_event.parsed.occurrences_between(min, max).map do |o|
        CalendarOccurrence.new(start_at: o.start_time,
                               end_at: o.end_time,
                               calendar_event_id: calendar_event.id)
      end
      CalendarOccurrence.import(occurrences)
    end
  end
end
