// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add animation class
    this.element.classList.add("animate-fade-in");
    
    // Auto-remove after 4 seconds
    setTimeout(() => {
      this.element.classList.add("animate-fade-out");
    }, 4000);
  }
  
  remove() {
    // Remove the element if it has the fade-out class
    if (this.element.classList.contains("animate-fade-out")) {
      this.element.remove();
    }
  }
}