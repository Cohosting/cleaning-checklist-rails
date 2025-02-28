import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["item"]
  static values = { url: String }
  
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-drag-target='handle']",
      ghostClass: "bg-blue-100",
      onEnd: this.onEnd.bind(this)
    })
  }
  
  onEnd(event) {
    const id = event.item.dataset.id
    const sectionOrder = this.itemTargets.map(item => item.dataset.id)
    
    // Send the new order to the server
    fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ section_order: sectionOrder })
    })
  }
}