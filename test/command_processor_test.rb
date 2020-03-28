# frozen_string_literal: true

require_relative "test_helper"

class CommandProcessorTest < Minitest::Test
  def setup
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup

    @redis = DB.pool.checkout
    @subject = CommandProcessor
  end

  def teardown
    DB.pool.checkin
    @meeting.cleanup
  end

  def test_draw_command
    response = @subject.drawn_response("test", account: :account)
    assert_equal :unknown_meeting_id, response.type

    @meeting << {id: "foo", name: "bar"}

    response = @subject.drawn_response("test", account: :account)
    assert_equal :winner, response.type
    assert_instance_of Person, response.context[:person]

    @meeting.shared(person: "foo")

    response = @subject.drawn_response("test", account: :account)
    assert_equal :empty_draw, response.type
  end
end
