# frozen_string_literal: true

require "dotenv"
Dotenv.load

require "sinatra/base"
require "connection_pool"
require "redis"

require_relative "settings"
require_relative "models/db"
require_relative "models/meeting"
require_relative "event_processor"
require_relative "command_processor"
require_relative "zoom"


require_relative "app"
