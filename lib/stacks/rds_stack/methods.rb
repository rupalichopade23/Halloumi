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
        #test5
      end
    end
  end
end
