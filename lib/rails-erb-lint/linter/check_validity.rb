require 'gli'
require 'action_view'
require 'find'
require 'rainbow'

require_relative '../helpers/rails_erb_check'

include GLI::App

program_desc 'A simple lint tool for ERB Rails views.'

desc 'Check for syntax errors on views'
command :check do |c|
  c.switch :verbose, default_value: false
  c.action do |global_options, options|
    valid = []
    invalid = []
    erb_files = []

    path = Dir.getwd
    puts Rainbow("Checking for files in current directory: #{path}").green

    Find.find(path.to_s) do |f|
      next if FileTest.directory?(f)
      if /.*\.erb/.match(File.basename(f))
        erb_files << f
      end
    end

    erb_files.each do |f|
      if RailsErbCheck.valid_syntax?(File.read(f))
        puts Rainbow("#{f} => valid").green if options[:verbose]
        valid << f
      else
        puts Rainbow("#{f} => invalid").red
        invalid << f
      end
    end

    exit_now!("#{invalid.size} invalid files") if invalid.any?

    puts Rainbow("#{valid.size + invalid.size} files, no invalid files").yellow
  end
end

exit run(ARGV)
