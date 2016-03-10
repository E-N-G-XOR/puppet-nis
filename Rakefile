#require 'rubygems'
#require 'puppetlabs_spec_helper/rake_tasks'
#require 'puppet-lint'
#PuppetLint.configuration.send("disable_80chars")
#PuppetLint.configuration.send('disable_class_parameter_defaults')
require 'rake'
require 'puppet-lint'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end
