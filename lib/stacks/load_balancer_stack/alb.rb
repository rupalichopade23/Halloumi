module Concerns
  # VPC Resources for {FirstProject}
  module ELB
    module LoadBalancer
      extend ActiveSupport::Concern
      included do
        resource :elb_securitygroups,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "elbsecuritygrp" }
        end
        resource :publicsubnets,
                 type: Halloumi::VirtualResource do |r|
          r.parameter { "publicsubnet" }
        end
        # resource :web_application_load_balancers,
        #          type: Halloumi::LoadBalancerV2Configuration do |r|
        #   r.property(:certificate_arn) { "arn:aws:acm:eu-central-1:791181114834:certificate/3acc34d0-a8d6-4245-a5c3-a915be53a056" }
        #   r.property(:listener_port) { 443 }
        #   r.property(:listener_protocol) { "HTTPS" }
          
        #   r.property(:target_group_health_check_port) { 80 }
        #   r.property(:target_group_health_check_protocol) { "HTTP" }
          
        #   r.property(:target_group_port) { 80 }
        #   r.property(:target_group_protocol) { "HTTP" }
        #  end
        resource :application_loadbalancers,
                 type: Halloumi::AWS::ElasticLoadBalancingV2::LoadBalancer do |r|
          r.property(:type) { "application" }
          r.property(:scheme) { "internet-facing" }
          r.property(:security_groups) do
            [
              elb_securitygroup.ref
            ]
          end
          r.property(:subnets) do
            [
              publicsubnet.ref
            ]
          end 
          r.property(:subnets) do
            {
              "Fn::Split": [
                ",",
                publicsubnet.ref
              ]
            }
          end
        end
        resource :target_groups,
                 type: Halloumi::AWS::ElasticLoadBalancingV2::TargetGroup do |r|
          r.property(:name) { "TG1" }
          r.property(:port) { "80" }
          r.property(:protocol) { "HTTP" }
          r.property(:vpc_id) { vpc.ref }
        end 
        resource :alb_listeners,
                 type: Halloumi::AWS::ElasticLoadBalancingV2::Listener do |r|
          r.property(:load_balancer_arn) { application_loadbalancer.ref }
          r.property(:port) { "80" }
          r.property(:protocol) { "HTTP" }
          r.property(:default_actions) { 
            [{ TargetGroupArn: target_group.ref, Type: "forward" }]
           }
        end   
        output(:target_groups, "TGARN") { |r| r.ref}
        # resource :alb_configs,
        #          type: Halloumi::LoadBalancerV2Configuration do |r|
        #   r.property(:listener_port) { 80 }
        #   r.property(:listener_protocol) { "HTTP" }
        #   r.property(:target_group_port) { 80 }
        #   r.property(:target_group_protocol) { "HTTP" }
        #   r.property(:target_group_name) {"TGforELB"}
        # end

        # resource :albs,
        #          type: Halloumi::LoadBalancerV2 do |r|
        #   r.resource(:lbv2_configurations) { alb_configs }
        #   r.resource(:skeletons) { skeletons }
        
        #   # r.resource(:subnet_groups) do
        #   #   [
        #   #      publicsubnet.ref 
        #   #   ]
        #   # end
        # end
        # output(:albs, "TGARN") { |r| r.ref}
        
      end
    end
  end
end