# Clear existing data
Task.delete_all
SectionGroup.delete_all
Section.delete_all
Checklist.delete_all
Group.delete_all
Organization.delete_all
User.delete_all

# Create a user
user = User.create!(
  email_address: "admin@example.com",
  password: "password",
  password_digest: BCrypt::Password.create("password")
)

# Create an organization
organization = Organization.create!(
  name: "Example Home Services",
  owner: user
)

# # Create a few groups
# bedroom = organization.groups.create!(name: "Bedroom", description: "Tasks related to bedroom cleaning")
# bathroom = organization.groups.create!(name: "Bathroom", description: "Bathroom maintenance")
# kitchen = organization.groups.create!(name: "Kitchen", description: "Kitchen cleaning")
# interior = organization.groups.create!(name: "Interior", description: "General interior maintenance and cleaning")

# # Create one checklist
# checklist = organization.checklists.create!(
#   title: "Property Turnover Checklist",
#   description: "Checklist for preparing a property between guests"
# )

# # Create sections
# cleaning = checklist.sections.create!(title: "Cleaning")
# inspection = checklist.sections.create!(title: "Inspection")
# interior_section = checklist.sections.create!(title: "Interior Maintenance")

# # Assign groups to sections
# cleaning_bedroom = cleaning.section_groups.create!(group: bedroom)
# cleaning_bathroom = cleaning.section_groups.create!(group: bathroom)
# cleaning_kitchen = cleaning.section_groups.create!(group: kitchen)

# inspection_general = inspection.section_groups.create!(group: bedroom)
# inspection_bathroom = inspection.section_groups.create!(group: bathroom)

# interior_group = interior_section.section_groups.create!(group: interior)

# # Add tasks to sections
# cleaning_bedroom.tasks.create!([
#   { content: "Change bed linens", completed: false },
#   { content: "Dust surfaces", completed: false },
#   { content: "Vacuum floor", completed: false }
# ])

# cleaning_bathroom.tasks.create!([
#   { content: "Clean shower", completed: false },
#   { content: "Restock toiletries", completed: false },
#   { content: "Disinfect toilet", completed: false }
# ])

# cleaning_kitchen.tasks.create!([
#   { content: "Wipe down countertops", completed: false },
#   { content: "Clean inside microwave", completed: false },
#   { content: "Take out trash", completed: false }
# ])

# inspection_general.tasks.create!([
#   { content: "Check for damages", completed: false },
#   { content: "Ensure all lightbulbs work", completed: false }
# ])

# inspection_bathroom.tasks.create!([
#   { content: "Check plumbing for leaks", completed: false }
# ])

# interior_group.tasks.create!([
#   { content: "Dust all vents and fans", completed: false },
#   { content: "Check and replace air filters if needed", completed: false },
#   { content: "Inspect and clean windows", completed: false },
#   { content: "Ensure furniture is in good condition", completed: false }
# ])

# puts "Seeds created successfully!"
