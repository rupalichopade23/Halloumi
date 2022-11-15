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
          r.property(:generate_secret_string) {  { PasswordLength: 15 }  }
          r.property(:name) { "secretRDS" }           
        end
        resource :rdsdatabases,
                 type: Halloumi::RDS do |r|
          r.resource(:skeletons) { skeletons }
          r.property(:engine) { "MySQL" }
          r.property(:service_ip_offset) { 1 }
          r.property(:instance_class) { "db.t3.micro" }
          r.property(:engine_version) { "5.7.33" }
          r.property(:engine_family) { "mysql5.7" }
          r.property(:master_user_password) do
            {
              "Fn::Join": [
                "",
                 ["{{resolve:secretsmanager:",{"Ref": "Secret"},":SecretString}}"] 
                 ] 
            }
          end
        end
        resource :secretattaches,
                 type: Halloumi::AWS::SecretsManager::SecretTargetAttachment do |r|
          r.property(:secret_id) { secret.ref }
          r.property(:target_id) { rdsdatabase.ref }
          r.property(:target_type) { "AWS::RDS::DBInstance" }
        end
      end
    end
  end
end
###  r.property(:master_user_password) { secret.ref_arn }
        #  r.property(:bulk_group_parameters) { bulk_group_parameters }


