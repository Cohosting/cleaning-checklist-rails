# app/services/job_creation_service.rb
class JobCreationService
  attr_reader :job

  def initialize(property_id:, checklist_id:, date:)
    @property_id = property_id
    @checklist_id = checklist_id
    @date = date
    @job = nil
  end

  def call
    ActiveRecord::Base.transaction do
      create_job
      copy_checklist_structure_with_property_groups
    end
    @job
  rescue => e
    Rails.logger.error("Failed to create job: #{e.message}")
    raise e
  end

  private

  def create_job
    @job = Job.create!(
      property_id: @property_id,
      checklist_id: @checklist_id,
      date: @date,
      public_token: SecureRandom.hex(10)
    )
  end

  def copy_checklist_structure_with_property_groups
    # Preload everything in a single query to minimize database hits
    checklist = Checklist.includes(
      sections: { 
        section_groups: { 
          tasks: [] 
        } 
      }
    ).find(@checklist_id)
    
    # Preload property groups
    property_groups = PropertyGroup.where(property_id: @property_id).index_by(&:group_id)
    
    # Use bulk insert for job sections
    job_sections_data = checklist.sections.map do |section|
      {
        job_id: @job.id,
        title: section.title,
        position: section.position,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    # Skip if there are no sections
    return if job_sections_data.empty?
    
    # Bulk insert all job sections at once
    job_section_ids = {}
    JobSection.insert_all(job_sections_data).each_with_index do |result, index|
      job_section_ids[checklist.sections[index].id] = result["id"]
    end
    
    # Prepare data for job section groups bulk insert
    job_section_groups_data = []
    job_section_group_mapping = {}
    
    checklist.sections.each do |section|
      section.section_groups.each do |section_group|
        # Check if this group exists in the property's groups
        property_group = property_groups[section_group.group_id]
        
        # Skip this section group if property doesn't have this group
        next unless property_group
        
        # Get the quantity (default to 1 if not specified)
        quantity = property_group.quantity.presence || 1
        
        # Create multiple instances based on quantity
        quantity.times do |instance_index|
          job_section_group_id = SecureRandom.uuid # Temporary id for mapping
          
          # Add suffix for multiple instances (e.g., "Bathroom #1")
          suffix = quantity > 1 ? " ##{instance_index + 1}" : ""
          
          job_section_groups_data << {
            job_section_id: job_section_ids[section.id],
            group_id: section_group.group_id,
            position: section_group.position,
            name: section_group.group.name,
            description: section_group.group.description,
            created_at: Time.current,
            updated_at: Time.current,
            instance_number: instance_index + 1,
            display_suffix: suffix,
          
          }
          
          job_section_group_mapping[job_section_group_id] = {
            section_group_id: section_group.id,
            index: job_section_groups_data.length - 1,
            instance_index: instance_index
          }
        end
      end
    end
    
    # Skip if there are no section groups
    return if job_section_groups_data.empty?
    
    # Bulk insert all job section groups at once
    job_section_group_db_ids = {}
    JobSectionGroup.insert_all(job_section_groups_data).each_with_index do |result, index|
      job_section_group_id = job_section_group_mapping.keys[index]
      section_group_id = job_section_group_mapping[job_section_group_id][:section_group_id]
      instance_index = job_section_group_mapping[job_section_group_id][:instance_index]
      
      # We need to track both the section group and its instance number for proper task assignment
      instance_key = "#{section_group_id}_#{instance_index}"
      job_section_group_db_ids[instance_key] = result["id"]
    end
    
    # Prepare data for job tasks bulk insert
    job_tasks_data = []
    
    checklist.sections.each do |section|
      section.section_groups.each do |section_group|
        # Skip if property doesn't have this group
        property_group = property_groups[section_group.group_id]
        next unless property_group
        
        # Get the quantity (default to 1 if not specified)
        quantity = property_group.quantity.presence || 1
        
        # Create tasks for each instance
        quantity.times do |instance_index|
          # Create the instance key to look up the job section group id
          instance_key = "#{section_group.id}_#{instance_index}"
          job_section_group_id = job_section_group_db_ids[instance_key]
          
          # Add all tasks for this section group instance
          section_group.tasks.each do |task|
            job_tasks_data << {
              job_section_group_id: job_section_group_id,
              name: task.name,
              position: task.position,
              completed: false,
              created_at: Time.current,
              updated_at: Time.current,
              content: task.content,
              image_required: task.image_required
            }
          end
        end
      end
    end
    
    # Bulk insert all job tasks at once (if any)
    JobTask.insert_all(job_tasks_data) if job_tasks_data.any?
  end
end