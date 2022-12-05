module Concerns
  # Shared Methods for {FirstProject}.
  module RDS
    module Methods
      extend ActiveSupport::Concern

      included do
        def rds_config
          config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
          config["rds_database"]
        end

        def cluster_parameter_config
          config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
          config["database_parameters"]["cluster"]
        end

        def instance_parameter_config
          config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
          config["database_parameters"]["instance"]
        end
        # test6
      end
    end
  end
end
