module Concerns
  module RDS
    module Lambda
      extend ActiveSupport::Concern
      included do
        resource :lambda_ec2_roles,
                 type: Halloumi::AWS::IAM::Role do |r|
          r.property(:path) { "/" }
          r.property(:assume_role_policy_document) do
            {
              Version: "2012-10-17",
              Statement: [
                {
                  Effect: :Allow,
                  Principal: {
                    Service: "lambda.amazonaws.com"
                  },
                  Action: [
                    "sts:AssumeRole"
                  ]
                }
              ]
            }
          end
          r.property(:policies) do
            [
              {
                PolicyName: "AllowAccess",
                PolicyDocument: {
                  "Statement": [
                    {
                      "Effect": "Allow",
                      "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                      ],
                      "Resource": "arn:aws:logs:*:*:*"
                    },
                    {
                      "Effect": "Allow",
                      "Action": [
                        "ec2:DescribeInstances",
                        "ec2:CreateTags",
                        "ec2:DescribeRegions",
                        "ec2:StartInstances",
                        "ec2:StopInstances"
                      ],
                      "Resource": "*"
                    }
                  ]
                }
              }
            ]
          end
        end
        resource :lambda_EC2s,
                 type: Halloumi::AWS::Lambda::Function do |r|
          r.property(:code) { "./lambda/" }
          r.property(:handler) { "index.lambda_handler" }
          r.property(:memory_size) { 128 }
          r.property(:role) { lambda_ec2_role.ref_arn }
          r.property(:runtime) { "python3.8" }
          r.property(:timeout) { 60 }
        end
      end
    end
  end
end
