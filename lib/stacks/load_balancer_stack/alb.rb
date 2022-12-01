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
          r.property(:default_actions) do
            [{ TargetGroupArn: target_group.ref, Type: "forward" }]
          end
        end
        # rubocop:disable Style/SymbolProc
        output(:target_groups, "TGARN") { |r| r.ref }
        # rubocop:enable Style/SymbolProc
      end
    end
  end
end
