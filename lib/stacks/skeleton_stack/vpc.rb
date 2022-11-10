require "halloumi/flowlog"

module Concerns
  # VPC Resources for {RUPSHalloumi}
  module Skeleton
    module VPC
      extend ActiveSupport::Concern
      included do
        resource :skeletons, type: Halloumi::Skeleton do |r|
          r.property(:vpc_cidr_block) { vpc_cidr_block }
          r.property(:enable_dns_support) { true }
          r.property(:enable_dns_hostnames) { true }
        end

        resource :vpc_flow_logs,
                 type: Halloumi::FlowLog do |r|
          r.property(:retention_days) { 30 }
          r.property(:resource_type) { "VPC" }
          r.property(:traffic_type) { "ALL" }
          r.property(:resource_id) { skeleton.vpc.ref }
        end
        ## subnets for webserver
        resource :public_subnets,
                 type: Halloumi::AWS::EC2::Subnet,
                 amount: -> { vpc_public_subnet.length } do |r, index|
          r.property(:vpc_id) { skeleton.vpc.ref }
          r.property(:cidr_block) { vpc_public_subnet[ index ] }
          r.property(:availability_zone) do
            {
              'Fn::Select': [
                index,
                { 'Fn::GetAZs': aws_region }
              ]
            }
          end
          r.property(:map_public_ip_on_launch) { true }
        end
        ## route table association for public subnets
        resource :route_table_associations,
                 type: Halloumi::AWS::EC2::SubnetRouteTableAssociation,
                 amount: -> { vpc_public_subnet.length } do |r, index|
          r.property(:route_table_id) { skeleton.route_table.ref }
          r.property(:subnet_id) { public_subnets[index].ref }
        end
        ## output for public subnets
        output(:public_subnets, :name) do
          {
            "Fn::Join": [
              ",",
              public_subnets.map(&:ref)
            ]
          }
        end
        #output(:web_subnets, "test") { |r| r.ref }

        # EIP
        resource :elastic_ip_addresses,
                 type: Halloumi::AWS::EC2::EIP do |r|
          #r.property(:domain) {}
        end
        resource :nat_gateways,
                 type: Halloumi::AWS::EC2::NatGateway do |r|
          r.property(:allocation_id) { elastic_ip_address.ref_allocation_id }
          r.property(:subnet_id) { public_subnets[0].ref }
          #r.property(:domain) {}
        end
        resource :private_subnets,
                 type: Halloumi::AWS::EC2::Subnet,
                 amount: -> { vpc_private_subnet.length } do |r, index|
          r.property(:vpc_id) { skeleton.vpc.ref }
          r.property(:cidr_block) { vpc_private_subnet[ index ] }
          r.property(:availability_zone) do
            {
              'Fn::Select': [
                index,
                { 'Fn::GetAZs': aws_region }
              ]
            }
          end
        end
        
        resource :private_route_tables,
                 type: Halloumi::AWS::EC2::RouteTable do |r|
          r.property(:vpc_id) { skeleton.vpc.ref }

        end
        resource :private_routes,
                 type: Halloumi::AWS::EC2::Route do |r|
          r.property(:destination_cidr_block) {"0.0.0.0/0"}
          r.property(:nat_gateway_id) { nat_gateway.ref }
          r.property(:route_table_id) { private_route_table.ref }
        end

        resource :private_route_table_associations,
                 type: Halloumi::AWS::EC2::SubnetRouteTableAssociation,
                 amount: -> { vpc_private_subnet.length } do |r, index|
          r.property(:route_table_id) { private_route_table.ref }
          r.property(:subnet_id) { private_subnets[index].ref }
        end
        output(:private_subnets, :name) do
          {
            "Fn::Join": [
              ",",
              private_subnets.map(&:ref)
            ]
          }
        end
      end
    end
  end
end
