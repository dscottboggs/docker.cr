require "webmock"
require "../src/docker"

# require sample data here
require "./docker/container/sample_data"

# ensure the state of environment variables
ENV.delete("DOCKER_TLS_VERIFY")
ENV.delete("DOCKER_HOST")
ENV.delete("DOCKER_URL")
ENV.delete("DOCKER_CERT_PATH")

require "spec"
