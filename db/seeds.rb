# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Clear existing data
Property.destroy_all

# Create sample properties
3.times do |i|
  property = Property.create!(
    name: "Property #{i + 1}",
    address: "123 Street #{i + 1}, City"
  )

  # Create sample checklists for each property
  2.times do |j|
    checklist = property.checklists.create!(
      name: "Cleaning Checklist #{j + 1}",
      completed: false
    )

    # Create sample tasks for each checklist
    3.times do |k|
      checklist.tasks.create!(
        name: "Task #{k + 1}",
        completed: [true, false].sample
      )
    end
  end
end

puts "✅ Seeded sample data successfully!"
