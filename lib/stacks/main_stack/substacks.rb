module Concerns
  # Stacks for {RUPSHalloumi}
  module Main
    module Substacks
      extend ActiveSupport::Concern
      included do
        resource :skeleton_stacks,
                 type: Halloumi::AWS::CloudFormation::Stack do |r|
          r.property(:template_url) do
            "#{ENV["STACK_NAME"]}-skeleton-stack.json"
          end
        end
        resource :sg_stacks,
                 type: Halloumi::AWS::CloudFormation::Stack do |r|
          r.property(:template_url) do
            "#{ENV["STACK_NAME"]}-sg-stack.json"
          end
          r.property(:parameters) do
            { 
              SkeletonVpcId: skeleton_stack.ref_output_SkeletonVpcId,
              SkeletonInternetGatewayId: skeleton_stack.ref_output_SkeletonInternetGatewayId,
              SkeletonRouteTableId: skeleton_stack.ref_output_SkeletonRouteTableId
            }
          end
        end
        
        resource :loadbalancer_stacks,
                 type: Halloumi::AWS::CloudFormation::Stack do |r|
          r.property(:template_url) do
            "#{ENV["STACK_NAME"]}-load-balancer-stack.json"
          end
          r.property(:parameters) do
            { 
              publicsubnet: skeleton_stack.ref_output_PublicSubnetName,
              elbsecuritygrp: sg_stack.ref_output_ElbsecuritygroupSg,
              SkeletonVpcId: skeleton_stack.ref_output_SkeletonVpcId,
              SkeletonInternetGatewayId: skeleton_stack.ref_output_SkeletonInternetGatewayId,
              SkeletonRouteTableId: skeleton_stack.ref_output_SkeletonRouteTableId
            }
          end
        end

        resource :web_stacks,
                 type: Halloumi::AWS::CloudFormation::Stack,
                 amount: -> { with_ec2 } do |r|
          r.property(:template_url) do
            "#{ENV["STACK_NAME"]}-web-stack.json"
          end
          r.property(:parameters) do
            { 
              tgarn:loadbalancer_stack.ref_output_TargetGroupTgarn,
              publicsubnet: skeleton_stack.ref_output_PublicSubnetName,
              websecuritygrp: sg_stack.ref_output_WebsecuritygroupSg,
              SkeletonVpcId: skeleton_stack.ref_output_SkeletonVpcId,
              SkeletonInternetGatewayId: skeleton_stack.ref_output_SkeletonInternetGatewayId,
              SkeletonRouteTableId: skeleton_stack.ref_output_SkeletonRouteTableId
            }
          end
        end

        resource :rds_stacks,
                 type: Halloumi::AWS::CloudFormation::Stack do |r|
          r.property(:template_url) do
            "#{ENV["STACK_NAME"]}-rds-stack.json"
          end
          r.property(:parameters) do
            { 
              # tgarn:loadbalancer_stack.ref_output_TargetGroupTgarn,
              privatesubnet: skeleton_stack.ref_output_PrivateSubnetName,
              rdssecuritygrp: sg_stack.ref_output_RdssecuritygroupSg,
              SkeletonVpcId: skeleton_stack.ref_output_SkeletonVpcId,
              SkeletonInternetGatewayId: skeleton_stack.ref_output_SkeletonInternetGatewayId,
              SkeletonRouteTableId: skeleton_stack.ref_output_SkeletonRouteTableId
            }
          end
        end
      end
    end
  end
end
