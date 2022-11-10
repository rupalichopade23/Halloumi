class LoadBalancerStack < Halloumi::CompoundResource
  # Shared concerns
  include Concerns::Shared::Methods
  include Concerns::Shared::Properties
  include Concerns::Shared::Resources
  # Stack concerns
  include Concerns::ELB::LoadBalancer
  
  
end