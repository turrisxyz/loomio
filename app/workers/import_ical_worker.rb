require 'open-uri'


class ImportIcalWorker
  include Sidekiq::Worker

  def perform(url, user_id)
    CalendarService.import_events_from_file(open(url))
  end
end
