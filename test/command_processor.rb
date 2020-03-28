# frozen_string_literal: true

require_relative "test_helper"

class CommandProcessorTest < Minitest::Test
  def setup
    @meeting = Meeting.new(id: :test)
    @meeting.cleanup

    @redis = DB.pool.checkout
    @subject = EventProcessor
  end

  def teardown
    DB.pool.checkin
    @meeting.cleanup
  end

  def test_draw_command

  end
end
