# # Delete records in the correct order to avoid foreign key constraints
# puts "🗑️ Deleting existing data..."
# JobTask.destroy_all
# Job.destroy_all
# Task.destroy_all
# Checklist.destroy_all
# Property.destroy_all

# puts "🏡 Seeding properties..."
# property1 = Property.create!(name: "Oceanfront Villa", address: "123 Beach Ave")
# property2 = Property.create!(name: "Mountain Cabin", address: "456 Forest Rd")

# puts "📋 Seeding checklists..."
# checklist1 = Checklist.create!(property: property1, name: "Standard Cleaning")
# checklist2 = Checklist.create!(property: property1, name: "Deep Cleaning")
# checklist3 = Checklist.create!(property: property2, name: "Basic Cabin Cleanup")

# # ✅ Ensure default_checklist_id is properly assigned AFTER checklists are created
# property1.update!(default_checklist_id: checklist1.id)
# property2.update!(default_checklist_id: checklist3.id)

# puts "📝 Seeding tasks for checklists..."
# Task.create!(checklist: checklist1, name: "Vacuum floors")
# Task.create!(checklist: checklist1, name: "Change bed linens")
# Task.create!(checklist: checklist2, name: "Scrub kitchen")
# Task.create!(checklist: checklist2, name: "Sanitize bathrooms")
# Task.create!(checklist: checklist3, name: "Dust furniture")

# puts "🛠️ Seeding jobs..."
# job1 = Job.create!(property: property1, checklist_id: checklist1.id, date: Date.today)
# job2 = Job.create!(property: property2, checklist_id: checklist3.id, date: Date.today + 3)

# puts "✅ Seeding job tasks..."
# JobTask.create!(job: job1, name: "Vacuum floors", completed: false)
# JobTask.create!(job: job1, name: "Change bed linens", completed: false)
# JobTask.create!(job: job2, name: "Dust furniture", completed: false)

# puts "🎉 Seeding complete!"
