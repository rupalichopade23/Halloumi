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
        
        resource :rdssecuritygroups,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "rdssecuritygrp" }
        end
        resource :privatesubnets,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "privatesubnet" }
        end
        resource :secrets,
                 type: Halloumi::AWS::SecretsManager::Secret do |r|
          r.property(:generate_secret_string) {  { PasswordLength: 15, ExcludeCharacters: '/@" '}  }
          r.property(:name) { "secretRDS" }     
               
        end
        resource :rds_subnet_groups,
                 type: Halloumi::AWS::RDS::DBSubnetGroup do |r|
          r.property(:db_subnet_group_description) { "rds-subnet-group" }
          r.property(:subnet_ids) do
            {
              "Fn::Split": [
                ",",
                privatesubnet.ref
              ]
            }
          end
        end
        resource :rds_instances,
                 type: Halloumi::AWS::RDS::DBInstance do |r|
          r.property(:allocated_storage) { 20 }
          r.property(:engine) { "MYSQL" }
          r.property(:db_subnet_group_name) { rds_subnet_group.ref }
          r.property(:db_instance_class) { "db.t3.micro" }
          r.property(:vpc_security_groups) do
            [ 
              rdssecuritygroup.ref
            ]
          end 

          r.property(:engine_version) { "5.7.33" }
          r.property(:master_username) { "myuser" }
         # r.property(:master_user_password) { "mysqldbpassword" }
          r.property(:master_user_password) do
            {
              "Fn::Join": [
                "",
                ["{{resolve:secretsmanager:",{"Ref": "Secret"},":SecretString}}"] 
                ] 
            }
          end
          r.property(:db_name) { "mydb123" }
          
         # r.property(:db_cluster_identifier) { rds_cluster.ref }
          
         # r.property(:db_parameter_group_name) { rds_instance_parameter_group.ref }
          
        end
        # resource :rdsdatabases,
        #          type: Halloumi::RDS do |r|
        #   r.resource(:skeletons) { skeletons }
        #   r.property(:engine) { "MySQL" }
        #   r.property(:service_ip_offset) { 1 }
        #   r.property(:instance_class) { "db.t3.micro" }
        #   r.property(:engine_version) { "5.7.33" }
        #   r.property(:engine_family) { "mysql5.7" }
        #   r.property(:master_user_password) do
        #     {
        #       "Fn::Join": [
        #         "",
        #          ["{{resolve:secretsmanager:",{"Ref": "Secret"},":SecretString}}"] 
        #          ] 
        #     }
        #   end
        # end
        # resource :secretattaches,
        #          type: Halloumi::AWS::SecretsManager::SecretTargetAttachment do |r|
        #   r.property(:secret_id) { secret.ref }
        #   r.property(:target_id) { "RdsdatabaseRdsInstance" }
        #   r.property(:target_type) { "AWS::RDS::DBInstance" }
        # end
      end
    end
  end
end

