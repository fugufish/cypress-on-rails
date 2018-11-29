module CypressDev
  class Command
    attr_reader :command_options, :logger
    def initialize(options, logger)
      @command_options = options
      @logger = logger
    end

    def run
      raise NotImplementedError
    end
  end
end
