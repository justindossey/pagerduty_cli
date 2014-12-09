# Class to send resolutions to PagerDuty.
module PagerdutyCli
  # Send a resolve to PagerDuty.
  class Resolve
    def initialize(args)
      @me = 'pagerduty_resolve'
      parse_opts(args)
      require_event
      load_data
    end

    def self.resolve(args)
      new(args).send_resolve
    end

    def send_resolve
      Pagerduty.new(@api_key).get_incident(incident_key).resolve
      remove_incident_file
    end

    private

    include PagerdutyCli::Common

    def parse_opts(args)
      opt_parser = OptionParser.new do |opts|
        parse_common_options(opts)
      end
      opt_parser.parse! args
    end

    def remove_incident_file
      File.delete(incident_file)
    rescue Errno::ENOENT
      warn("No incident file found at #{incident_file}")
    end
  end
end
