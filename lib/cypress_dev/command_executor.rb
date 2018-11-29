require 'cypress_dev/configuration'
require 'cypress_dev/command'
module CypressDev
  # loads and evals the command files
  class CommandExecutor
    def self.load(file, logger, command_options = nil)
      load_cypress_helper
      class_name = "#{File.basename(file, ".rb").camelcase}Command"
      if Object.const_defined?(class_name.to_sym)
        Object.send(:remove_const, class_name.to_sym)
      end
      Kernel.load(file)
      unless Object.const_defined?(class_name.to_sym)
        raise LoadError, "Unable to load command #{class_name}, expected #{file} to define it"
      end
      class_name.constantize.new(command_options, logger).run
    rescue => e
      logger.error("fail to execute #{file}: #{e.message}")
      logger.error(e.backtrace.join("\n"))
      raise e
    end

    def self.load_cypress_helper
      cypress_helper_file = "#{configuration.cypress_folder}/cypress_helper"
      if File.exist?("#{cypress_helper_file}.rb")
        Kernel.require cypress_helper_file
      else
        logger.warn "could not find #{cypress_helper_file}.rb"
      end
    end

    def self.logger
      configuration.logger
    end

    def self.configuration
      CypressDev.configuration
    end
  end
end
