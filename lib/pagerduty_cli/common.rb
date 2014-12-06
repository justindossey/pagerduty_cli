# Module for common functionality to pagerduty CLI classes
module PagerdutyCli
  # Common functionality to pagerduty interaction
  module Common
    API_KEY_FILE = '/etc/pagerduty_api.key'
    def load_data
      @api_key = File.open(@options[:api_key_file]).read.chomp
    rescue Errno::ENOENT, Errno::EPERM
      croak("Could not open PD API key file at #{@options[:api_key_file]}.")
    end

    def croak(message)
      $stderr.puts "#{@me} Error: #{message} Exiting."
      exit 1
    end

    def warn(message)
      $stderr.puts "#{@me} Warning: #{message}"
    end

    def incident_key
      event_key = "#{@options[:host]}:#{@options[:event]}"
      Digest::SHA1.hexdigest(event_key)
    end

    # return the name for our incident state file.
    def incident_file
      File.join(@options[:tmpdir], "pagerduty-#{incident_key}")
    end

    # Disabling the MethodLength cop here because any reduction would reduce
    # readability.
    # rubocop:disable MethodLength
    def parse_common_options(opts)
      opts.banner = "Usage: #{@me} [options]"
      @options ||= {}
      @options.merge!(host: ENV['HOSTNAME'],
                      api_key_file: API_KEY_FILE,
                      tmpdir: '/tmp')
      opts.on('-H', '--host HOST', 'Report from the hostname given') do |h|
        @options[:host] = h
      end
      opts.on('-k', '--keyfile KEYFILE',
              'Use the key specified in file KEYFILE') do |kf|
        @options[:api_key_file] = kf
              end
      opts.on('-e', '--event EVENT', 'Report the event given') do |e|
        @options[:event] = e
      end
      opts.on('-t', '--tmpdir PATH',
              'location for incident files') do |tmp|
        @options[:tmpdir] = tmp
      end
      opts.on_tail('-h', '--help', 'Show this message') do
        $stderr.puts opts
        exit
      end
    end
    # rubocop:enable MethodLength
  end
end
