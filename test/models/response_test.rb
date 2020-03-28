# frozen_string_literal: true

require_relative "../test_helper"

class ResponseTest < Minitest::Test
  def setup
    @redis = DB.pool.checkout
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup
  end

  def teardown
    @meeting.cleanup
    DB.pool.checkin
  end

  def test_winner
    person = Person.new({
      meeting_id: :test,
      id: :foo,
      name: :bar
    })
    response = Response.winner(person)

    assert_equal :winner, response.type
    assert_instance_of Hash, response.as_json(additional_context)
  end

  def test_unknown_meeting_id
    response = Response.unknown_meeting_id(:foo)

    assert response.sendable?
    assert_equal :unknown_meeting_id, response.type
    assert_instance_of Hash, response.as_json(additional_context)
  end

  def test_person_sharing
    response = Response.person_sharing(:foo)

    assert response.sendable?
    assert_equal :person_sharing, response.type
    assert_instance_of Hash, response.as_json(additional_context)
  end

  def test_sharing_reset
    response = Response.sharing_reset(:foo)

    assert response.sendable?
    assert_equal :sharing_reset, response.type
    assert_instance_of Hash, response.as_json(additional_context)
  end

  def test_empty_draw
    response = Response.empty_draw(:foo)

    assert response.sendable?
    assert_equal :empty_draw, response.type
    assert_instance_of Hash, response.as_json(additional_context)
  end

  def test_blank
    response = Response.blank

    assert_equal :blank, response.type
    refute response.sendable?
  end

  def additional_context
    {
      account_id: :account,
      to_jid: :to_jid,
      robot_jid: :robot_jid
    }
  end

end
