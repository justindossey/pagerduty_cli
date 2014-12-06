# encoding: utf-8

require 'optparse'
require 'pagerduty'
require 'digest/sha1'

require_relative 'common'

# Send a PagerDuty alert.
module PagerdutyCli
  # Send a trigger to PagerDuty
  class Trigger
    def initialize(args)
      @me = 'pagerduty_trigger'
      parse_opts(args)
      load_data
      return unless @options[:force] || !incident_is_too_fresh?
      touch_incident_file unless @options[:no_touch]
    end

    class << self
      def trigger(args)
        new(args).send_trigger
      end
    end

    def send_trigger
      Pagerduty.new(@api_key).trigger(incident_description,
                                      incident_key: incident_key,
                                      client: @options[:host])
    end

    private

    include PagerdutyCli::Common

    # Disabling the MethodLength cop here because any reduction would reduce
    # readability.
    # rubocop:disable MethodLength
    def parse_opts(args)
      # default options
      @options = {}
      @options[:interval] = (4 * 60 * 60 + 1)

      opt_parser = OptionParser.new do |opts|
        parse_common_options(opts)
        opts.on('-f', '--force',
                'Force the event to process, even if not fresh') do
          @options[:force] = true
        end
        opts.on('-n', '--no-incident',
                'Do not record sending this incident') do
          @options[:no_touch] = true
        end
        opts.on('-i', '--touch-interval INTERVAL',
                'Specify freshness interval in seconds') do |interval|
          @options[:interval] = interval.to_i
        end
      end
      opt_parser.parse! args
    end
    # rubocop:enable MethodLength

    # return true if this incident has been reported in the past 4 hrs 1 min
    def incident_is_too_fresh?
      cutoff = Time.now - @options[:interval]
      File.exist?(incident_file) && File.mtime(incident_file) > cutoff
    end

    def incident_description
      "#{@options[:event]} failed on #{@options[:host]}"
    end

    def touch_incident_file
      File.open(incident_file, 'a') do |f|
        f.puts "#{Time.now}: #{incident_description}"
      end
    rescue Errno::EPERM
      croak("Could not write incident file #{incident_file.inspect}")
    end
  end
end
