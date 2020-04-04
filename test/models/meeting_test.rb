require_relative "../test_helper"

class MeetingTest < Minitest::Test
  def setup
    @redis = DB.pool.checkout
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup
    @person = Person.new(id: :foo, name: :bar)
  end

  def teardown
    @meeting.cleanup
    DB.pool.checkin
  end

  def test_wedges_add_person_to_meeting
    @meeting << @person

    assert_equal "set", @redis.type(@meeting.key)
    assert_equal "bar", Person.find(id: @person.id).name
  end

  def test_other_wedges_removes_person_from_meeting
    @meeting << @person

    @meeting >> @person
    assert_equal "none", @redis.type(@meeting.key)
    assert_nil Person.find(id: @person.id).name
  end

  def test_shared_adds_to_called_on_list
    assert_equal "none", @redis.type(@meeting.key)
    @meeting << @person
    @meeting.shared(@person)

    assert_equal "set", @redis.type(@meeting.key)
  end

  def test_draw
    # Empty meetings
    person = @meeting.draw
    assert_instance_of Person, person
    assert person.empty?

    @meeting << @person
    person = @meeting.draw

    # Valid sharer
    assert_equal "foo", person.id

    # Everyone has shared
    @meeting.shared(@person)
    person = @meeting.draw
    assert person.empty?


    # multiple people
    @meeting << Person.new(id: :baz, name: :bap)
    person = @meeting.draw
    assert_equal "baz", person.id
  end

  def test_clear_shared
    @meeting.shared(@person)

    assert_equal "set", @redis.type(@meeting.called_on_key)

    @meeting.clear_shared

    assert_equal "none", @redis.type(@meeting.called_on_key)
  end
end
