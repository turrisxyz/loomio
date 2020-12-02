require 'rails_helper'
describe 'Generating CalendarOccurrences' do
  it "one off event" do
    user = create :user
    file = File.open(Rails.root.join('spec/fixtures/ical/1_one_off_event.ics'))
    one_off_event = CalendarService.import(file, user.id)
    assert CalendarOccurrence.where(start_at: DateTime.parse('20201201T223000Z'),
                                    end_at: DateTime.parse('20201201T233000Z')).exists?
    assert CalendarOccurrence.count == 1
  end

  it "moves one off event" do
    user = create :user
    file1 = File.open(Rails.root.join('spec/fixtures/ical/1_one_off_event.ics'))
    CalendarService.import(file1, user.id)

    file2 = File.open(Rails.root.join('spec/fixtures/ical/2_move_one_off_event.ics'))
    CalendarService.import(file2, user.id)
    expect(CalendarEvent.count).to eq 2
    expect(CalendarOccurrence.where( start_at: Time.zone.parse('20201202T000000Z'), end_at: Time.zone.parse('20201202T010000Z')).count).to be(1)
  end

  it 'recurring event' do
    user = create :user
    file = File.open(Rails.root.join('spec/fixtures/ical/3_repeat_each_wednesday.ics'))
    CalendarService.import(file, user.id)
    expect(CalendarEvent.count).to eq 1
    expect(CalendarOccurrence.first.start_at).to eq Time.zone.parse("2020-12-02 02:00:00")
    expect(CalendarOccurrence.first.end_at).to eq Time.zone.parse("2020-12-02 03:00:00")
    expect(CalendarOccurrence.second.start_at).to eq Time.zone.parse("2020-12-09 02:00:00")
    expect(CalendarOccurrence.second.end_at).to eq Time.zone.parse("2020-12-09 03:00:00")
  end

  it 'recurring event change to daily' do
    user = create :user
    file = File.open(Rails.root.join('spec/fixtures/ical/3_repeat_each_wednesday.ics'))
    CalendarService.import(file, user.id)
    file = File.open(Rails.root.join('spec/fixtures/ical/4_change_to_repeat_daily.ics'))
    CalendarService.import(file, user.id)
    expect(CalendarEvent.count).to eq 2
    expect(CalendarOccurrence.first.start_at).to eq Time.zone.parse("2020-12-02 02:00:00")
    expect(CalendarOccurrence.first.end_at).to eq Time.zone.parse("2020-12-02 03:00:00")
    expect(CalendarOccurrence.second.start_at).to eq Time.zone.parse("2020-12-03 02:00:00")
    expect(CalendarOccurrence.second.end_at).to eq Time.zone.parse("2020-12-03 03:00:00")
  end

  it 'cancel one occurrence of repeating event' do
    user = create :user
    file = File.open(Rails.root.join('spec/fixtures/ical/3_repeat_each_wednesday.ics'))
    CalendarService.import(file, user.id)
    file = File.open(Rails.root.join('spec/fixtures/ical/4_change_to_repeat_daily.ics'))
    CalendarService.import(file, user.id)
    file = File.open(Rails.root.join('spec/fixtures/ical/5_cancel_one_occurrence_of_repeating_event.ics'))
    CalendarService.import(file, user.id)
    expect(CalendarEvent.count).to eq 3
    expect(CalendarOccurrence.first.start_at).to eq Time.zone.parse("2020-12-02 02:00:00")
    expect(CalendarOccurrence.first.end_at).to eq Time.zone.parse("2020-12-02 03:00:00")
    expect(CalendarOccurrence.second.start_at).to eq Time.zone.parse("2020-12-04 02:00:00")
    expect(CalendarOccurrence.second.end_at).to eq Time.zone.parse("2020-12-04 03:00:00")
  end

  it 'move one occurrence back one hour' do
    user = create :user
    file = File.open(Rails.root.join('spec/fixtures/ical/3_repeat_each_wednesday.ics'))
    CalendarService.import(file, user.id)
    file = File.open(Rails.root.join('spec/fixtures/ical/4_change_to_repeat_daily.ics'))
    CalendarService.import(file, user.id)
    file = File.open(Rails.root.join('spec/fixtures/ical/5_cancel_one_occurrence_of_repeating_event.ics'))
    CalendarService.import(file, user.id)
    file = File.open(Rails.root.join('spec/fixtures/ical/6_move_one_occurrence_back_one_hour.ics'))
    CalendarService.import(file, user.id)
    expect(CalendarEvent.count).to eq 4
    expect(CalendarOccurrence.first.start_at).to eq Time.zone.parse("2020-12-02 02:00:00")
    expect(CalendarOccurrence.first.end_at).to eq Time.zone.parse("2020-12-02 03:00:00")
    expect(CalendarOccurrence.second.start_at).to eq Time.zone.parse("2020-12-04 01:00:00")
    expect(CalendarOccurrence.second.end_at).to eq Time.zone.parse("2020-12-04 02:00:00")
  end


  # end
  #
  # it 'imports a recurring event with some occurences moved' do
  # end
end
