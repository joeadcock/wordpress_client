rspec_options = {
  cmd: 'rspec -f documentation',
  failed_mode: :keep,
  all_after_pass: true,
  all_on_start: true,
  run_all: {cmd: 'rspec -f progress'}
}

guard :rspec, rspec_options do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  watch("lib/wpclient.rb") { rspec.spec_dir }
  dsl.watch_spec_files_for(%r{^lib/wpclient/(.*)\.rb$})
end
