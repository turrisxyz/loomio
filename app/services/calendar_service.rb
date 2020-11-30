
module CalendarService
  def self.import_events(file)
    events = Icalendar::Event.parse(open(url)).map do |event|
      CalendarEvent.new(
        uid: event.uid,
        user_id: user_id,
        title: event.summary,
        start_at: event.dtstart,
        end_at: event.dtend,
        sequence: event.sequence,
        recurrence_id: event.recurrence_id,
        summary: event.summary,
        status: event.status,
        tranps: (event.transp == "TRANSPARENT"),
        ical: event.to_ical
      )
    end
    CalendarEvent.import events, on_duplicate_key_ignore: true
  end

  def generate_occurances
    CalendarEvent.find_each do |calendar_event|
      calendar_event
    end
  end
end
