require_relative "../test_helper"

class PersonTest < Minitest::Test
  def setup
    @redis = DB.pool.checkout
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup

    @person = Person.new(id: :foo, name: :bar)
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
end
