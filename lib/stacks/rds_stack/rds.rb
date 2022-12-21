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
        # def aurora_cluster_parameter_group_parameters
        #   puts cluster_parameter_config
        #   cluster_parameter_config
        #   # params =
        #   # {
        #   #   "time_zones": cluster_parameter_config["time_zone"],
        #   #   "character_set_database": cluster_parameter_config[
        #   #     "character_set_database"],
        #   #   "character_set_server": cluster_parameter_config[
        #   #     "character_set_server"]
        #   # }
        #   # params
        # end
        # def aurora_instance_parameter_group_parameters
        #   parameters =
        #    {
        #      "max_allowed_packet": instance_parameter_config[
        #        "max_allowed_packet"],
        #      "event_scheduler": instance_parameter_config["event_scheduler"]
        #    }
        #    parameters
        # end
        def aurora_cluster_parameter_group_parameters
          params =
          {
            "time_zone": cluster_parameter_config["time_zone"],
            "character_set_database": cluster_parameter_config[
              "character_set_database"],
            "character_set_server": cluster_parameter_config[
              "character_set_server"]
          }
          params
        end

        def aurora_instance_parameter_group_parameters
          parameters =
          {
            "max_allowed_packet": instance_parameter_config[
              "max_allowed_packet"],
            "event_scheduler": instance_parameter_config["event_scheduler"]
          }
          parameters
        end
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
          r.property(:generate_secret_string) do
            {
              PasswordLength: 15,
              ExcludeCharacters: '/@" '
            }
          end

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
        resource :cluster_parameter_groups,
                 type: Halloumi::AWS::RDS::DBClusterParameterGroup do |r|

          r.property(:description) { "DB cluster parameter group" }
          r.property(:family) { rds_config["database_engine_family"] }
          r.property(:parameters) do
            aurora_cluster_parameter_group_parameters
          end
        end
        resource :instance_parameter_groups,
                 type: Halloumi::AWS::RDS::DBParameterGroup do |r|
          r.property(:description) { "DB parameter group" }
          r.property(:family) { rds_config["database_engine_family"] }
          r.property(:parameters) do
            aurora_instance_parameter_group_parameters
          end
        end
        resource :database_clusters,
                 type: Halloumi::AWS::RDS::DBCluster do |r|
          r.property(:db_cluster_parameter_group_name) do
            cluster_parameter_group.ref
          end
          r.property(:db_subnet_group_name) { rds_subnet_group.ref }
          r.property(:engine) { rds_config["engine"] }
          r.property(:engine_version) { rds_config["engine_version"] }
          r.property(:master_username) do
            rds_config["master_username"]
          end
          r.property(:master_user_password) do
            {
              "Fn::Join":
              [
                "",
                [
                  "{{resolve:secretsmanager:",
                  { "Ref": "Secret" }, ":SecretString}}"
                ]
              ]
            }
          end
          r.property(:storage_encrypted) do
            rds_config["storage_encryption"]
          end
          r.property(:vpc_security_group_ids) do
            [
              rdssecuritygroup.ref
            ]
          end
        end
        resource :aurora_instances,
                 type: Halloumi::AWS::RDS::DBInstance,
                 amount: -> { with_aurora * rds_config["database_instances_count"].to_i } do |r|
          r.property(:db_cluster_identifier) { database_cluster.ref }
          r.property(:db_instance_class) { rds_config["db_instance_type"] }
          r.property(:db_parameter_group_name) do
            instance_parameter_group.ref
          end
          r.property(:db_subnet_group_name) { rds_subnet_group.ref }
          r.property(:engine) { rds_config["engine"] }
          r.property(:publicly_accessible) { false }
        end
        # resource :rds_instances,
        #          type: Halloumi::AWS::RDS::DBInstance do |r|
        #   r.property(:allocated_storage) { 20 }
        #   r.property(:engine) { "MYSQL" }
        #   r.property(:db_subnet_group_name) { rds_subnet_group.ref }
        #   r.property(:db_instance_class) { "db.t3.micro" }
        #   r.property(:vpc_security_groups) do
        #     [
        #       rdssecuritygroup.ref
        #     ]
        #   end

        #   r.property(:engine_version) { "5.7.33" }
        #   r.property(:master_username) { "myuser" }
        #   r.property(:master_user_password) do
        #     {
        #       "Fn::Join": [
        #         "",
        #         ["{{resolve:secretsmanager:", { "Ref": "Secret" },
        #          ":SecretString}}"]
        #       ]
        #     }
        #   end
        #   r.property(:db_name) { "mydb123" }
        # end
      end
    end
  end
end
