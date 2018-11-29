module CypressDev
  class Command
    attr_reader :command_options
    def initialize(options)
      @command_options = options
    end

    def run
      raise NotImplementedError
    end
  end
end
