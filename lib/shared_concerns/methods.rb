# frozen_string_literal: true

module Concerns
  # Shared Methods for {RUPSHalloumi}.
  module Shared
    module Methods
      extend ActiveSupport::Concern

      included do
        # Return the first character of the environment name.
        def environment_first_char
          ENV["ENVIRONMENT"][0]
        end

        # Return the 5 random characters associated with the
        # first character of your environment.
        def domain_suffix
          offset = environment_first_char.ord - 97
          ENV["SUFFIX_CHARACTERS"][offset..offset + 4]
        end

        # Return the complete fqdn for your environment. This domain name
        # is pseudo random and unique per environment.
        def calc_hosted_zone_name(_argument = nil)
          %w(
            SUFFIX_CHARACTERS
            CUSTOMER_SHORT_NAME
            CUSTOMER_PROJECT_ID
          ).each do |var|
            fail "ENV var `#{var}` is required." if ENV[var].nil?
          end
          [
            environment_first_char,
            ENV["CUSTOMER_SHORT_NAME"],
            ENV["CUSTOMER_PROJECT_ID"],
            domain_suffix,
            ".net"
          ].join.downcase
        end

        # def launch_config
        #   config=YAML.load_file("config/S3/#{ENV["STACK_NAME"]}.yml")
        #   config["s3_buckets"]
        # end
        # def launch_amount
        #   s3_config.length
        # end

        def with_ec2
          ENV["DELETE_EC2"].to_s.strip.casecmp("true").zero? ? 0 : 1
        end
        def with_aurora
          ENV["DELETE_AURORA"].to_s.strip.casecmp("true").zero? ? 0 : 1
        end
      end
    end
  end
end
