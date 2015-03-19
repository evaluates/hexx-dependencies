# encoding: utf-8
require "hexx-rspec"

# Loads runtime metrics
Hexx::RSpec.load_metrics_for(self)

# Loads the code under test
require "hexx-dependencies"
