# frozen_string_literal: true

# Bind to 127.0.0.1 to avoid issue with MacOS and `getaddrinfo`
# causing ruby crashes during asset compilation and startup.
# https://bugs.ruby-lang.org/issues/15763
listen '127.0.0.1:3000'
