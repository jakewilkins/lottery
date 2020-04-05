# frozen_string_literal: true

class Person
  KEY_PATTERN = "person:%<id>s"
  ACTIVE_MEETINGS_PATTERN = "#{KEY_PATTERN}:active-meetings"

  def self.empty(meeting_id:)
    new(id: :empty, meeting_id: meeting_id, name: "Everyone has shared!")
  end

  def self.find(id:)
    new(id: id).tap {|e| e.hydrate}
  end

  def self.get(id:, name:, timezone:)
    new(id: id, name: name, timezone: timezone)
  end

  attr_reader :meeting_id, :id, :name, :timezone
  attr_writer :meeting_id
  attr_reader :joined_times

  def initialize(id:, name: nil, meeting_id: nil, timezone: nil)
    @meeting_id, @id, @name = meeting_id, id, name
    @joined_times = {}
    @timezone = timezone
  end

  def participating_in(meeting_id:, joined_at: nil)
    DB do |conn|
      if !conn.exists(key)
        save
      end
      @joined_times[meeting_id] = joined_at || now
      conn.hset(active_meetings_key, meeting_id, @joined_times[meeting_id])
    end
  end

  def empty?
    id == :empty
  end

  def cleanup(meeting_id:)
    DB do |conn|
      conn.hdel(active_meetings_key, meeting_id)
      if !conn.exists(active_meetings_key)
        conn.del(key)
      end
    end
  end

  def joined_at_time(for_meeting_id = nil)
    for_meeting_id ||= meeting_id

    raise "must supply a meeting id to get a joined at time" unless for_meeting_id

    time = @joined_times[meeting_id]

    raise "This person isn't in this meeting ?!?!" unless time

    time = Time.iso8601(time)

    time.to_meaningful
  end

  def save
    DB do |conn|
      conn.mapped_hmset(key, {name: name, timezone: timezone})
    end
  end

  def hydrate
    DB do |conn|
      hash = conn.hgetall(key)
      @name = hash['name']
      @timezone = hash['timezone']
      @joined_times = conn.hgetall(active_meetings_key)
    end
  end

  def key
    KEY_PATTERN % {id: id}
  end

  def active_meetings_key
    ACTIVE_MEETINGS_PATTERN % {id: id}
  end

  def now
    Time.now.iso8601
  end
end
