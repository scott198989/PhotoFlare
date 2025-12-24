import { Controller } from "@hotwired/stimulus"

// Post Controller
// Handles post interactions like double-tap to like
export default class extends Controller {
  static targets = ["heartOverlay", "likeButton"]

  connect() {
    this.lastTap = 0
  }

  // Double-tap to like
  like(event) {
    const now = Date.now()
    const timeSinceLastTap = now - this.lastTap

    if (timeSinceLastTap < 300 && timeSinceLastTap > 0) {
      // Double tap detected - trigger like
      this.showHeartAnimation()
      this.triggerLike()
    }

    this.lastTap = now
  }

  // Show the heart overlay animation
  showHeartAnimation() {
    if (this.hasHeartOverlayTarget) {
      const overlay = this.heartOverlayTarget
      overlay.classList.add('show')

      // Remove the class after animation completes
      setTimeout(() => {
        overlay.classList.remove('show')
      }, 800)
    }
  }

  // Trigger the like action
  triggerLike() {
    // Find the like button and click it if not already liked
    const likeBtn = this.element.querySelector('[data-like-button]')
    if (likeBtn && !likeBtn.classList.contains('liked')) {
      likeBtn.click()
    }
  }
}
