# db/seeds/organizations.rb
# You can run this with: rails db:seed:organizations

# Find user with ID 1 or skip if not found
user = User.find_by(id: 1)

if user.nil?
  puts "User with ID 1 not found. Please create a user first."
  exit
end

# Create organizations
organizations = [
  { name: "Acme Corporation", owner_id: user.id },
  { name: "Globex Industries", owner_id: user.id },
  { name: "Stark Enterprises", owner_id: user.id },
  { name: "Wayne Innovations", owner_id: user.id },
  { name: "Umbrella Corp", owner_id: user.id }
]

organizations.each do |org_data|
  org = Organization.find_or_create_by(name: org_data[:name]) do |o|
    o.owner_id = org_data[:owner_id]
  end
  
  # Create membership if it doesn't exist
  unless user.memberships.exists?(organization_id: org.id)
    role = org.owner_id == user.id ? 'admin' : 'member'
    user.memberships.create!(organization: org, role: role)
  end
  
  puts "Created or updated organization: #{org.name}"
end

# Set the first organization as the current one for the user
if user.organization_id.nil? && user.organizations.any?
  user.update(organization_id: user.organizations.first.id)
  puts "Set #{user.organizations.first.name} as the current organization for #{user.email_address}"
end

puts "Finished creating organizations for user #{user.email_address} (ID: #{user.id})"