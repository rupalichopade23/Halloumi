module Concerns
  # VPC Resources for {FirstProject}
  module EC2
    module SecurityGroup
      extend ActiveSupport::Concern
      included do
        resource :elbsecuritygroups,
                  type: Halloumi::AWS::EC2::SecurityGroup do |r|
          r.property(:group_description) { "ELB SG" }
          r.property(:group_name) { "ELB" }
          r.property(:vpc_id) { vpc.ref }
        end
        resource :elb_sg_http_inbounds,
                  type: Halloumi::AWS::EC2::SecurityGroupIngress do |r|
          r.property(:cidr_ip) { "0.0.0.0/0" }
          r.property(:ip_protocol) { "tcp" }
          r.property(:from_port) { 80 }
          r.property(:to_port) { 80 }
          r.property(:group_id) { elbsecuritygroup.ref }
        end
        resource :elb_sg_https_inbounds,
                  type: Halloumi::AWS::EC2::SecurityGroupIngress do |r|
          r.property(:cidr_ip) { "0.0.0.0/0" }
          r.property(:ip_protocol) { "tcp" }
          r.property(:from_port) { 443 }
          r.property(:to_port) { 443 }
          r.property(:group_id) { elbsecuritygroup.ref }
        end
        resource :websecuritygroups,
                  type: Halloumi::AWS::EC2::SecurityGroup do |r|
          r.property(:group_description) { "Web SG" }
          r.property(:group_name) { "Web" }
          r.property(:vpc_id) { vpc.ref }
        end
        resource :web_sg_http_inbounds,
                  type: Halloumi::AWS::EC2::SecurityGroupIngress do |r|
          r.property(:source_security_group_id) { elbsecuritygroup.ref }
          r.property(:ip_protocol) { "tcp" }
          r.property(:from_port) { 80 }
          r.property(:to_port) { 80 }
          r.property(:group_id) { websecuritygroup.ref }
        end
        resource :web_sg_ssh_inbounds,
                  type: Halloumi::AWS::EC2::SecurityGroupIngress do |r|
          #r.property(:source_security_group_id) { bastion_security_group.ref }
          r.property(:cidr_ip) { "0.0.0.0/0" }
          r.property(:ip_protocol) { "tcp" }
          r.property(:from_port) { 22 }
          r.property(:to_port) { 22 }
          r.property(:group_id) { websecuritygroup.ref }
        end
        resource :rdssecuritygroups,
                  type: Halloumi::AWS::EC2::SecurityGroup do |r|
          r.property(:group_description) { "RDS SG" }
          r.property(:group_name) { "RDS" }
          r.property(:vpc_id) { vpc.ref }
        end
        resource :rds_sg_inbounds,
                  type: Halloumi::AWS::EC2::SecurityGroupIngress do |r|
          r.property(:source_security_group_id) { websecuritygroup.ref }
          r.property(:ip_protocol) { "tcp" }
          r.property(:from_port) { 3306 }
          r.property(:to_port) { 3306 }
          r.property(:group_id) { rdssecuritygroup.ref }
        end
        
        output(:websecuritygroups, "SG") { |r| r.ref }
        output(:elbsecuritygroups, "SG") { |r| r.ref }
        output(:rdssecuritygroups, "SG") { |r| r.ref }
      end
    end
  end
end