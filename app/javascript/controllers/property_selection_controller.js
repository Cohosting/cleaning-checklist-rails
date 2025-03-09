// app/javascript/controllers/property_selection_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]
  
  connect() {
    this.updateCounter()
    
    // Add event listeners to the buttons
    document.getElementById('select-all-btn')?.addEventListener('click', () => this.selectAll())
    document.getElementById('clear-all-btn')?.addEventListener('click', () => this.clearAll())
    
    // Add event listeners to checkboxes for counter update and styling
    this.checkboxTargets.forEach(checkbox => {
      checkbox.addEventListener('change', (e) => {
        const container = e.target.closest('.relative')
        if (container) {
          if (e.target.checked) {
            container.classList.add('ring-2', 'ring-blue-500', 'bg-blue-50')
          } else {
            container.classList.remove('ring-2', 'ring-blue-500', 'bg-blue-50')
          }
        }
        this.updateCounter()
      })
    })
  }
  
  selectAll() {

    console.log(`selectAll()`)
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = true
      
      // Also update the styling of the parent container
      const container = checkbox.closest('.relative')
      if (container) {
        container.classList.add('ring-2', 'ring-blue-500', 'bg-blue-50')
      }
    })
    this.updateCounter()
  }
  
  clearAll() {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
      
      // Also update the styling of the parent container
      const container = checkbox.closest('.relative')
      if (container) {
        container.classList.remove('ring-2', 'ring-blue-500', 'bg-blue-50')
      }
    })
    this.updateCounter()
  }
  
  updateCounter() {
    const selectedCount = this.checkboxTargets.filter(checkbox => checkbox.checked).length
    const counterElement = document.getElementById('selected-count')
    if (counterElement) {
      counterElement.textContent = selectedCount
    }
  }
}