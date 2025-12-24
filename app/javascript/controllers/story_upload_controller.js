import { Controller } from "@hotwired/stimulus"

// Story Upload Controller
// Handles uploading new stories
export default class extends Controller {
  static targets = ["input", "form"]

  // Open file picker
  openPicker() {
    if (this.hasInputTarget) {
      this.inputTarget.click()
    }
  }

  // Handle file selection and upload
  upload() {
    if (!this.hasInputTarget || !this.hasFormTarget) return

    const file = this.inputTarget.files[0]
    if (!file) return

    // Validate file type
    const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/webm', 'video/quicktime']
    if (!validTypes.includes(file.type)) {
      alert('Please select a valid image or video file.')
      return
    }

    // Validate file size (max 50MB)
    const maxSize = 50 * 1024 * 1024
    if (file.size > maxSize) {
      alert('File is too large. Maximum size is 50MB.')
      return
    }

    // Submit the form
    this.formTarget.requestSubmit()
  }
}
