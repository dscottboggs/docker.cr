require "json"
require "openssl"
require "http"
require "./docker/client/errors"
require "./core_ext/**"
require "./docker/*"

module Docker
  extend self
  @@client : Docker::APIClient

  def client
    @@client ||= Docker::APIClient.new
  end
end
