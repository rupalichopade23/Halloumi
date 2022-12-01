module Concerns
  # VPC Resources for {FirstProject}
  module EC2
    module WebServer
      extend ActiveSupport::Concern
      included do
        resource :webserversecuritygroups,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "websecuritygrp" }
        end
        resource :publicsubnets,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "publicsubnet" }
        end
        resource :tgarns,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "tgarn" }
        end
        property :image_id,
                 env:  :WEB_AMI,
                 required: true
        property :instance_type,
                 env:  :WEB_INSTANCE_TYPE,
                 required: true
        # IAM SSM ROle
        resource :ssm_roles,
                 type: Halloumi::AWS::IAM::Role do |r|
          r.property(:assume_role_policy_document) do
            {
              Version: "2012-10-17",
              Statement: [
                {
                  Effect: :Allow,
                  Principal: {
                    Service: "ec2.amazonaws.com"
                  },
                  Action: [
                    "sts:AssumeRole"
                  ]
                }
              ]
            }
          end
          r.property(:managed_policy_arns) do
            [
              "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
            ]
          end
        end
        resource :ssm_role_instance_profiles,
                 type: Halloumi::AWS::IAM::InstanceProfile do |r|
          r.property(:roles) do
            [
              ssm_role.ref
            ]
          end
        end
        resource :launch_configurations,
                 type: Halloumi::AWS::AutoScaling::LaunchConfiguration do |r|
          r.property(:image_id) { image_id }
          r.property(:instance_type) { instance_type }
          r.property(:security_groups) do
            [
              webserversecuritygroup.ref
            ]
          end
          r.property(:associate_public_ip_address) { true }
          r.property(:user_data) do
            { 'Fn::Base64': web_user_data
            }
          end
          r.property(:iam_instance_profile) { ssm_role_instance_profile.ref }
        end
        # resource :launch_templates,
        #          type: Halloumi::AWS::EC2::LaunchTemplate do |r|
        #   r.property(:launch_template_data) do
        #     {
        #       "ImageId":  image_id,
        #       "InstanceType": instance_type,
        #       "SecurityGroups": [
        #         webserversecuritygroup.ref
        #       ],
        #       #"AssociatePublicIpAddress": true,
        #       "UserData":
        #         {
        #         'Fn::Base64': web_user_data
        #         }
        #  #    "IamInstanceProfile":
        #     }
        #   end
        # end
        resource :autoscalinggroups,
                 type: Halloumi::AWS::AutoScaling::AutoScalingGroup do |r|
          r.property(:desired_capacity) { ec2_config["desired"] }
          r.property(:max_size) { ec2_config["max"] }
          r.property(:min_size) { ec2_config["min"] }
          r.property(:vpc_zone_identifier) do
            [
              publicsubnet.ref
            ]
          end
          r.property(:target_group_arns) do
            [
              tgarn.ref
            ]
          end
          r.property(:launch_configuration_name) { launch_configuration.ref }
        end
      end
    end
  end
end
