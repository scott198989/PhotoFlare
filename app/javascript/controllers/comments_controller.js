import { Controller } from "@hotwired/stimulus"

// Comments Controller
// Handles comment form interactions
export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.toggleSubmit()
  }

  // Check input and enable/disable submit button
  toggleSubmit() {
    if (this.hasInputTarget && this.hasSubmitTarget) {
      const hasContent = this.inputTarget.value.trim().length > 0
      this.submitTarget.disabled = !hasContent
    }
  }

  // Called when form is submitted successfully
  clear() {
    this.element.reset()
    this.toggleSubmit()
  }

  // Auto-resize textarea
  resize() {
    if (this.hasInputTarget) {
      this.inputTarget.style.height = 'auto'
      this.inputTarget.style.height = Math.min(this.inputTarget.scrollHeight, 80) + 'px'
    }
  }
}
