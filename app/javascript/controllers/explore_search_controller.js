import { Controller } from "@hotwired/stimulus"

// Explore Search Controller
// Handles live search functionality on the explore page
export default class extends Controller {
  static targets = ["input", "clearBtn"]
  static values = {
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
    this.updateClearButton()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  // Live search with debounce
  liveSearch() {
    this.updateClearButton()

    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      this.search()
    }, this.debounceValue)
  }

  // Submit search form
  search(event) {
    if (event) event.preventDefault()

    const query = this.inputTarget.value.trim()
    if (query.length > 0) {
      const form = this.element.querySelector('form')
      if (form) {
        form.requestSubmit()
      }
    }
  }

  // Clear search input
  clear() {
    this.inputTarget.value = ''
    this.inputTarget.focus()
    this.updateClearButton()

    // Navigate to explore index
    window.location.href = '/explore'
  }

  // Show/hide clear button
  updateClearButton() {
    if (this.hasClearBtnTarget) {
      const hasValue = this.inputTarget.value.trim().length > 0
      this.clearBtnTarget.style.display = hasValue ? 'flex' : 'none'
    }
  }
}
