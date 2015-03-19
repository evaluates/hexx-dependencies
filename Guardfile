# encoding: utf-8

guard :rspec, cmd: "bundle exec rspec" do

  watch(%r{^lib/hexx/dependencies/(\w+)\.rb$}) do |m|
    "spec/tests/#{ m[1] }_spec.rb"
  end

  watch(%r{^lib/hexx/dependencies/cli/.+}) { "spec/tests/cli_spec.rb" }

  watch(%r{^spec/tests/.+_spec\.rb$})

  watch("lib/hexx.rb")              { "spec" }
  watch("lib/hexx/dependencies.rb") { "spec" }
  watch("spec/spec_helper.rb")      { "spec" }

end # guard :rspec
