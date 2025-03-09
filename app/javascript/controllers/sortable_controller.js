// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="sortable"
export default class extends Controller {
  static targets = ["item"]
  static values = {
    resourceUrl: String
  }
  
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: ".drag-handle",
      ghostClass: "bg-yellow-50",
      onEnd: this.end.bind(this)
    })
  }
  
  end(event) {
    const id = event.item.dataset.id
    const newPosition = event.newIndex + 1
    
    // Send the new position to the server
    fetch(this.resourceUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getMetaValue("csrf-token")
      },
      body: JSON.stringify({
        id: id,
        position: newPosition
      })
    }).catch(error => {
      console.error("Error:", error)
    })
  }
  
  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element.getAttribute("content")
  }
  
  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }
}