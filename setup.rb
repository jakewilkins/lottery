# frozen_string_literal: true

require "dotenv"
Dotenv.load

require "sinatra/base"
require "connection_pool"
require "redis"
require "erb"
require "yaml"
require "json"
require "pathname"
require "net/http"
require "uri"
require "meaningful_time"

require_relative "app/settings"
require_relative "app/event_processor"
require_relative "app/command_processor"
require_relative "app/interaction_processor"
require_relative "app/zoom"
require_relative "models/db"
require_relative "models/meeting"
require_relative "models/response"
require_relative "models/person"


require_relative "app"
