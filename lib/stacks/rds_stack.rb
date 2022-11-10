class RDSStack < Halloumi::CompoundResource
  # Shared concerns
  include Concerns::Shared::Methods
  include Concerns::Shared::Properties
  include Concerns::Shared::Resources
  # Stack concerns
  include Concerns::RDS::DBInstance
  
end
