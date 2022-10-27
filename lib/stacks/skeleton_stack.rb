# frozen_string_literal: true

# SkeletonStack for project "RUPSHalloumi".
class SkeletonStack < Halloumi::CompoundResource
  # Shared concerns
  include Concerns::Shared::Methods
  include Concerns::Shared::Properties

  # Stack concerns
  include Concerns::Skeleton::VPC
end
