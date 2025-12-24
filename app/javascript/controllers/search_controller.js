import { Controller } from "@hotwired/stimulus"

// Search Controller
// Handles the navbar search functionality with live results
export default class extends Controller {
  static targets = ["input", "results"]
  static values = {
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  search() {
    // Clear previous timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    const query = this.inputTarget.value.trim()

    // Hide results if query is empty
    if (query.length === 0) {
      this.hideResults()
      return
    }

    // Debounce the search
    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceValue)
  }

  async performSearch(query) {
    if (query.length < 1) return

    try {
      // Show loading state
      this.resultsTarget.classList.add('loading')
      this.showResults()

      // The form already has turbo-frame handling, so we just need to submit
      // For now, we trigger the turbo frame update
      const form = this.element.querySelector('form')
      if (form) {
        // Let Turbo handle the form submission
        form.requestSubmit()
      }
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      this.resultsTarget.classList.remove('loading')
    }
  }

  showResults() {
    if (this.hasResultsTarget && this.inputTarget.value.trim().length > 0) {
      this.resultsTarget.classList.add('show')
    }
  }

  hideResults() {
    if (this.hasResultsTarget) {
      // Small delay to allow clicking on results
      setTimeout(() => {
        this.resultsTarget.classList.remove('show')
      }, 200)
    }
  }

  // Clear search input
  clear() {
    this.inputTarget.value = ''
    this.hideResults()
    this.inputTarget.focus()
  }
}
