import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "content", 
    "collapseBtn", 
    "groupForm", 
    "newGroupName", 
    "existingGroups", 
    "groupSelect"
  ]

  static values = {
    organizationId: String,
    checklistId: String,
    sectionId: String
  }

  toggleCollapse(event) {
    const content = this.contentTarget
    const button = this.collapseBtnTarget

    if (content.classList.contains("hidden")) {
      // Expand
      content.classList.remove("hidden")
      button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
        </svg>
      `
    } else {
      // Collapse
      content.classList.add("hidden")
      button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
        </svg>
      `
    }
  }

  toggleGroupForm() {
    this.groupFormTarget.classList.toggle("hidden")
  }

  cancelGroupForm() {
    this.groupFormTarget.classList.add("hidden")
    this.newGroupNameTarget.value = ""

    if (this.hasExistingGroupsTarget) {
      this.existingGroupsTarget.classList.add("hidden")
    }
  }

  toggleExistingGroups() {
    this.existingGroupsTarget.classList.toggle("hidden")
  }

  addGroup() {
    const groupName = this.newGroupNameTarget.value.trim();
    const hasExistingGroups = this.hasExistingGroupsTarget && !this.existingGroupsTarget.classList.contains("hidden");
    const selectedGroupId = hasExistingGroups ? this.groupSelectTarget.value : null;

    // Check if we're adding an existing group
    if (selectedGroupId) {
      this.addExistingGroup(selectedGroupId);
    } 
    // Or creating a new one
    else if (groupName) {
      this.createNewGroup(groupName);
    }

    // Hide the form
    this.cancelGroupForm();
  }

  addExistingGroup(groupId) {
    const csrfToken = document.querySelector("meta[name='csrf-token']").content;
    
    // Check your network tab to confirm the URL is correct
    console.log(`Sending request to: /organizations/${this.organizationIdValue}/checklists/${this.checklistIdValue}/sections/${this.sectionIdValue}/section_groups`);
    
    // Use FormData instead of JSON to match Rails' expected format
    const formData = new FormData();
    // Try directly sending group_id instead of nesting it
    formData.append('group_id', groupId);
    // Also send it in the nested format in case controller uses strong params
    formData.append('section_group[group_id]', groupId);
    formData.append('authenticity_token', csrfToken);
    
    fetch(`/organizations/${this.organizationIdValue}/checklists/${this.checklistIdValue}/sections/${this.sectionIdValue}/section_groups`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html, application/json'
      },
      body: formData
    })
    .then(response => {
      console.log('Response status:', response.status);
      
      if (!response.ok) {
        throw new Error(`Server responded with status: ${response.status}`);
      }
      
      const contentType = response.headers.get('Content-Type');
      console.log('Content-Type:', contentType);
      
      if (contentType && contentType.includes('text/vnd.turbo-stream.html')) {
        return response.text().then(html => {
          console.log('Received Turbo Stream HTML:', html);
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, 'text/html');
          const streamElements = doc.querySelectorAll('turbo-stream');
          
          if (streamElements.length > 0) {
            streamElements.forEach(streamElement => {
              // Process each turbo-stream element
              Turbo.renderStreamMessage(streamElement.outerHTML);
            });
          } else {
            console.warn('No turbo-stream elements found in response');
            // Fallback - reload only if necessary
            window.location.reload();
          }
        });
      } else if (contentType && contentType.includes('application/json')) {
        return response.json().then(data => {
          console.log('Received JSON response:', data);
          // Handle JSON response - might need to refresh
          window.location.reload();
        });
      } else {
        console.log('Unhandled content type, refreshing page');
        window.location.reload();
      }
    })
    .catch(error => {
      console.error("Error adding existing group:", error);
      
      // Try to get more error details from the response if possible
      if (error.response) {
        error.response.text().then(text => {
          console.error('Error response body:', text);
        }).catch(e => {
          console.error('Could not parse error response:', e);
        });
      }
      
      alert("Failed to add the group. Please check the console for details.");
    });
  }

  createNewGroup(groupName) {
    const csrfToken = document.querySelector("meta[name='csrf-token']").content;

    // Use FormData for consistency with Rails
    const formData = new FormData();
    formData.append('group[name]', groupName);
    formData.append('authenticity_token', csrfToken);

    fetch(`/organizations/${this.organizationIdValue}/groups`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.id) {
        this.addExistingGroup(data.id);
      }
    })
    .catch(error => {
      console.error("Error creating group:", error);
      alert("Failed to create the group. Please try again.");
    });
  }
}