#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "Installing dependencies..."
bundle install

echo "Precompiling assets..."
bundle exec rails assets:precompile
bundle exec rails assets:clean

echo "Running database migrations..."
bundle exec rails db:migrate