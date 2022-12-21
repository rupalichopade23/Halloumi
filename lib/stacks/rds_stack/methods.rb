module Concerns
  # Shared Methods for {FirstProject}.
  module RDS
    module Methods
      extend ActiveSupport::Concern

      included do
        # def rds_config
        #   config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
        #   config["rds_database"]
        # end

        # def get_parameter_config(param)
        #   config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
        #   config["database_parameters"][param]
        #   param.to_json # convert ruby hash to json
        # end
        # # puts get_parameter_config("cluster")
        # # puts get_parameter_config("instance")

        # def cluster_parameter_config
        #   config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
        #   config["database_parameters"]["cluster"]
        # end

        # def instance_parameter_config
        #   config = YAML.load_file("config/database/#{ENV["STACK_NAME"]}.yml")
        #   config["database_parameters"]["instance"]
        # end
        # test7
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
      end
    end
  end
end
