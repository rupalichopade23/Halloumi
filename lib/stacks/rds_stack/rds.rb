module Concerns
  # VPC Resources for {FirstProject}
  module RDS
    module DBInstance
      extend ActiveSupport::Concern
      included do
        # property :database_master_username,
        #          env: :DATABASE_MASTER_USERNAME,
        #          required: true

        # property :database_master_user_password,
        #          env: :DATABASE_MASTER_USER_PASSWORD,
        #          required: true
        resource :secrets,
                 type: Halloumi::AWS::SecretsManager::Secret do |r|
          r.property(:generate_secret_string) { { PasswordLength: 15 } }
          r.property(:name) { "secretRDS" }   
         # r.property(:secret_string) { "secretRDS123" }    

                   
        end
        resource :rdsdatabases,
                 type: Halloumi::RDS do |r|
          r.resource(:skeletons) { skeletons }
          r.property(:engine) { "MySQL" }
          r.property(:service_ip_offset) { 1 }
          r.property(:instance_class) { "db.t2.small" }
          r.property(:engine_version) { "5.6.22" }
          r.property(:engine_family) { "mysql5.6" }
          r.property(:master_user_password) { secret.ref }


        end
      end
    end
  end
end

