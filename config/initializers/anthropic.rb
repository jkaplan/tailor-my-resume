# The anthropic gem reads ANTHROPIC_API_KEY from the environment by default.
# Source it from Rails encrypted credentials so the key never sits in a plain
# file: `bin/rails credentials:edit` and add `anthropic_api_key: sk-ant-...`.
ENV["ANTHROPIC_API_KEY"] ||= Rails.application.credentials.anthropic_api_key
