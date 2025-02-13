#!/bin/sh

# usage:
#
# `source mock-ci-env.sh`
# `bundle exec fastlane ...`
#
#  e.g.
# `bundle exec fastlane ios test --env default`
# `bundle exec fastlane ios release --env default`
# `bundle exec fastlane ios renew_code_signing --env default`
# 
# NOTE: when switching between lanes/jobs, you might need to `unset` env vars or create a new shell

export MATCH_PASSWORD=<...>

## Uncomment only if you want to use `app_store_connect_api_key`, e.g. before using `pilot` to upload to TestFlight 
export APPSTORE_CONNECT_KEY_CONTENT_BASE64=<...>
