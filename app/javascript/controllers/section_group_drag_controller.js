// app/javascript/controllers/section_group_drag_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["item"]
  static values = { 
    organizationId: Number,
    checklistId: Number,
    sectionId: Number,
    url: String
  }
  
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-section-group-drag-target='handle']",
      ghostClass: "bg-blue-100",
      group: "section-groups", // This enables dragging between different sections
      onEnd: this.onEnd.bind(this)
    })
  }
  
  onEnd(event) {
    if (!event.item) return;
    
    // Extract the section_group ID from the dragged item
    const sectionGroupId = this.getSectionGroupId(event.item);
    
    // Make sure we have a valid ID
    if (!sectionGroupId) {
      console.error("No valid section group ID found");
      return;
    }
    
    const newPosition = event.newIndex + 1;
    
    // Find the target section ID from the destination container
    const targetContainer = event.to;
    if (!targetContainer) return;
    
    const targetElement = targetContainer.closest("[data-section-group-drag-section-id-value]");
    if (!targetElement) {
      console.error("Could not find target section element");
      return;
    }
    
    const targetSectionId = targetElement.dataset.sectionGroupDragSectionIdValue;
    if (!targetSectionId) {
      console.error("No target section ID found");
      return;
    }
    
    // If moved within the same section, just reorder
    if (targetSectionId === this.sectionIdValue.toString() && event.oldIndex !== event.newIndex) {
      const groupOrder = this.itemTargets.map(item => this.getSectionGroupId(item));
      
      fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ group_order: groupOrder })
      });
    } 
    // If moved to a different section
    else if (targetSectionId !== this.sectionIdValue.toString()) {
      const url = `/organizations/${this.organizationIdValue}/checklists/${this.checklistIdValue}/sections/${this.sectionIdValue}/section_groups/${sectionGroupId}/move_to_section`;
      
      fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html, application/json'
        },
        body: JSON.stringify({ 
          target_section_id: targetSectionId,
          position: newPosition
        })
      })
      .then(response => {
        if (!response.ok) {
          throw new Error(`Error: ${response.status}`);
        }
        
        // Check if the response is a Turbo Stream
        const contentType = response.headers.get('Content-Type');
        if (contentType && contentType.includes('text/vnd.turbo-stream.html')) {
          return response.text();
        }
        return response.json();
      })
      .then(data => {
        console.log("Successfully moved group");
        
        // If it's JSON data, manually update the form URLs
        if (typeof data === 'object') {
          // Find the task form in the moved section group and update it
          const formContainer = document.getElementById(`new_task_form_section_group_${sectionGroupId}`);
          if (formContainer) {
            // Request a fresh form with the correct section ID
            // Note: using the member route for new_task_form
            fetch(`/organizations/${this.organizationIdValue}/checklists/${this.checklistIdValue}/sections/${targetSectionId}/section_groups/${sectionGroupId}/new_task_form`, {
              headers: {
                'Accept': 'text/html',
                'X-Requested-With': 'XMLHttpRequest'
              }
            })
            .then(response => response.text())
            .then(html => {
              formContainer.innerHTML = html;
            })
            .catch(error => {
              console.error("Error refreshing task form:", error);
            });
          }
        }
      })
      .catch(error => {
        console.error("Error moving group:", error);
      });
    }
  }
  
  // Helper method to get section group ID from item
  getSectionGroupId(item) {
    // Try to get ID from data-id attribute first (more reliable)
    if (item.dataset && item.dataset.id) {
      return item.dataset.id;
    }
    
    // Fallback to parsing the DOM ID
    const frameId = item.id;
    return frameId ? frameId.split('_').pop() : null;
  }
}