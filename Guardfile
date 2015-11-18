rspec_options = {
  cmd: 'rspec -f documentation -t focus',
  failed_mode: :keep,
  all_after_pass: true,
  all_on_start: true,
  run_all: {cmd: 'rspec -f progress -t focus'}
}

guard :rspec, rspec_options do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  watch("spec/shared_examples/term_examples.rb") do
    [
      "spec/category_spec.rb",
      "spec/tag_spec.rb",
    ]
  end

  # Ruby files
  watch("lib/wpclient.rb") { rspec.spec_dir }
  dsl.watch_spec_files_for(%r{^lib/wpclient/(.*)\.rb$})
end
