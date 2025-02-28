// app/javascript/controllers/task_drag_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["item"]
  static values = {
     organizationId: Number,
     checklistId: Number,
     sectionId: Number,
     sectionGroupId: Number
  }
  
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-task-drag-target='handle']",
      ghostClass: "bg-blue-100",
      group: "tasks",
      onEnd: this.onEnd.bind(this)
    })
  }
  
  onEnd(event) {
    if (!event.item) return;
    
    // Extract the task ID from the turbo-frame ID
    const frameId = event.item.id;
    const taskId = frameId ? frameId.split('_').pop() : null;
    
    // Make sure we have a valid ID
    if (!taskId || taskId === "undefined") return;
    
    const newPosition = event.newIndex + 1;
    const targetContainer = event.to;
    if (!targetContainer) return;
    
    const targetElement = targetContainer.closest("[data-task-drag-section-group-id-value]");
    if (!targetElement) return;
    
    const targetSectionGroupId = targetElement.dataset.taskDragSectionGroupIdValue;
    if (!targetSectionGroupId) return;
    
    const targetSectionElement = targetElement.closest("[data-task-drag-section-id-value]");
    const targetSectionId = targetSectionElement ? targetSectionElement.dataset.taskDragSectionIdValue : this.sectionIdValue;
    
    // Only send update if something changed
    if (targetSectionGroupId !== this.sectionGroupIdValue.toString() || event.oldIndex !== event.newIndex) {
      const url = `/organizations/${this.organizationIdValue}/checklists/${this.checklistIdValue}/sections/${targetSectionId}/section_groups/${targetSectionGroupId}/tasks/${taskId}/move`;
      
      // Send the task's new position to the server, expecting Turbo Stream response
      fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html, application/json'
        },
        body: JSON.stringify({
           position: newPosition,
           section_group_id: targetSectionGroupId,
           original_section_id: this.sectionIdValue,
           original_section_group_id: this.sectionGroupIdValue
        })
      })
      .then(response => {
        if (response.headers.get('Content-Type')?.includes('text/vnd.turbo-stream.html')) {
          return response.text().then(html => {
            // Process Turbo Stream response
            const template = document.createElement('template');
            template.innerHTML = html;
            const streams = template.content.querySelectorAll('turbo-stream');
            streams.forEach(stream => document.body.appendChild(stream));
          });
        } else {
          return response.json();
        }
      })
      .catch(error => {
        console.error("Error moving task:", error);
        // Revert the UI change on error
        if (this.sortable) {
          this.sortable.sort(Array.from(this.element.children));
        }
      });
    }
  }
}