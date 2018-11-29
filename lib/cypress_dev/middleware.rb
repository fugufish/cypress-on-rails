require 'json'
require 'rack'
require 'cypress_dev/configuration'
require 'cypress_dev/command_executor'

module CypressDev
  # Middleware to handle cypress commands and eval
  class Middleware
    def initialize(app, command_executor = CommandExecutor, file = ::File)
      @app              = app
      @command_executor = command_executor
      @file             = file
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path.start_with?('/__cypress__/command')
        configuration.tagged_logged { handle_command(request) }
      else
        @app.call(env)
      end
    end

    private

    def configuration
      CypressDev.configuration
    end

    def logger
      configuration.logger
    end


    def command_from_body(body)
      command_params = body.is_a?(Array) ? body : [body]
      command_params.map do |params|
        { file_path: file_path_for(params["name"]), options: params["options"] }
      end
    end

    def file_path_for(name)
      "#{configuration.cypress_folder}/app_commands/#{name}.rb"
    end

    def handle_command(req)
      body = JSON.parse(req.body.read)
      logger.info "handle_command: #{body}"
      commands        = command_from_body(body)
      missing_command = commands.find { |command| !@file.exists?(command[:file_path]) }
      if missing_command.nil?
        results = commands.map { |command| @command_executor.load(command[:file_path], logger, command[:options]) }
          .select { |r| r.is_a? String }
        [201, {}, [{ callbacks: results }]]
      else
        [404, {}, ["could not find command file: #{missing_command[:file_path]}"]]
      end
    end
  end
end
