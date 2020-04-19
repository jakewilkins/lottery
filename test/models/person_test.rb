require_relative "../test_helper"

class PersonTest < Minitest::Test
  def setup
    @redis = DB.pool.checkout
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup

    @person = Person.new(id: :foo, name: :bar, timezone: "America/Los_Angeles")
  end

  def teardown
    @meeting.cleanup
    @redis.del @person.key
    @redis.del @person.active_meetings_key
    DB.pool.checkin
  end

  def test_find_hydrates_name_attribute
    @person.save
    person = Person.find(id: @person.id)

    assert_equal "bar", person.name
  end

  def test_empty_returns_an_empty_boy
    person = Person.empty(meeting_id: @meeting.id)

    assert_equal :empty, person.id
    assert_equal @meeting.id, person.meeting_id
  end

  def test_participating_in
    @person.participating_in(meeting_id: @meeting.id)

    assert_includes @redis.hkeys(@person.active_meetings_key), @meeting.id.to_s
  end

  def test_cleanup_removes_info_for_meeting
    @person.participating_in(meeting_id: @meeting.id)

    @person.cleanup(meeting_id: @meeting.id)

    refute_includes @redis.hkeys(@person.active_meetings_key), @meeting.id.to_s
  end

  def test_in?
    refute @person.in?(meeting_id: @meeting.id)
    @meeting << @person

    assert @person.in?(meeting_id: @meeting.id)
  end

  def test_tracks_joined_times_for_meetings
    time = Time.now.iso8601
    @person.participating_in(meeting_id: @meeting.id, joined_at: time)

    person = Person.find(id: @person.id)
    assert_equal time, person.joined_times[@meeting.id.to_s]
  end

  def test_persists_timezone_info
    assert_equal @person.timezone, "America/Los_Angeles"
    @person.save
    person = Person.find(id: @person.id)
    assert_equal person.timezone, "America/Los_Angeles"
  end

  def test_joined_at_time
    time = Time.iso8601("2020-04-04T15:48:32-07:00")
    @person.participating_in(meeting_id: @meeting.id, joined_at: time.iso8601)

    @person.meeting_id = @meeting.id

    assert_includes @person.joined_at_time, "ago"
  end
end
