import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.classList.add("pf-flash-dismissing")

    setTimeout(() => {
      this.element.remove()

      // Remove container if empty
      const container = document.querySelector(".pf-flash-container")
      if (container && container.children.length === 0) {
        container.remove()
      }
    }, 300)
  }
}
