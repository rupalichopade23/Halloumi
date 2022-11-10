module Concerns
  # Shared Methods for {FirstProject}.
  module EC2
    module Methods
      extend ActiveSupport::Concern

      included do
        def ec2_config
          config=YAML.load_file("config/EC2/#{ENV["STACK_NAME"]}.yml")
        end
      end
    end
  end
end