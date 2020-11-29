require 'open-uri'

class ImportIcalWorker
  include Sidekiq::Worker

  def perform(url, user_id)
    events = Icalendar::Event.parse(open(url)).map do |event|
      CalendarEvent.new(
        uid: event.uid,
        user_id: user_id,
        title: event.summary,
        start_at: event.dtstart,
        end_at: event.dtend,
      )
    end
    CalendarEvent.import events, on_duplicate_key_ignore: true
  end
end
