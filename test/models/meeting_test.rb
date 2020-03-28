require_relative "../test_helper"

class MeetingTest < Minitest::Test
  def setup
    @redis = DB.pool.checkout
    @meeting = Meeting.new(id: :test)
    @meeting.cleanup
  end

  def teardown
    @meeting.cleanup
    DB.pool.checkin
  end

  def test_wedges_add_person_to_meeting
    @meeting << {id: :foo, name: :bar}

    assert_equal "set", @redis.type("meeting:test")
    assert_equal "bar", @redis.get("meeting:test:foo")
  end

  def test_other_wedges_removes_person_from_meeting
    @meeting << {id: :foo, name: :bar}

    @meeting >> {id: :foo}
    assert_equal "none", @redis.type("meeting:test")
    assert_nil @redis.get("meeting:test:foo")
  end

  def test_shared_adds_to_called_on_list
    assert_equal "none", @redis.type("meeting:test:called")
    @meeting << {id: :foo, name: :bar}
    @meeting.shared(person: :foo)

    assert_equal "set", @redis.type("meeting:test:called")
  end

  def test_draw
    # Empty meetings
    person = @meeting.draw
    assert_instance_of Person, person
    assert person.empty?

    @meeting << {id: :foo, name: :bar}
    person = @meeting.draw

    # Valid sharer
    assert_equal "foo", person.id

    # Everyone has shared
    @meeting.shared(person: :foo)
    person = @meeting.draw
    assert person.empty?


    # multiple people
    @meeting << {id: :baz, name: :bap}
    person = @meeting.draw
    assert_equal "baz", person.id
  end

  def test_clear_shared
    @meeting.shared(person: :foo)

    assert_equal "set", @redis.type("meeting:test:called")

    @meeting.clear_shared

    assert_equal "none", @redis.type("meeting:test:called")
  end
end
