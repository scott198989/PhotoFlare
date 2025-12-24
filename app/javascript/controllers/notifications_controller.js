import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["badge", "dropdown", "list", "count"]

  connect() {
    this.subscribeToChannel()
    this.updateBadgeCount()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create("NotificationsChannel", {
      received: (data) => {
        this.handleNotification(data)
      }
    })
  }

  handleNotification(data) {
    if (data.type === "new_notification") {
      this.incrementBadge()
      this.prependNotification(data.html)
      this.playNotificationSound()
    } else if (data.type === "mark_read") {
      this.decrementBadge()
      this.markAsReadInUI(data.notification_id)
    }
  }

  incrementBadge() {
    if (this.hasBadgeTarget) {
      const currentCount = parseInt(this.badgeTarget.textContent) || 0
      this.badgeTarget.textContent = currentCount + 1
      this.badgeTarget.classList.add("pf-notification-badge-pulse")
      this.badgeTarget.style.display = "flex"
    }
  }

  decrementBadge() {
    if (this.hasBadgeTarget) {
      const currentCount = parseInt(this.badgeTarget.textContent) || 0
      const newCount = Math.max(0, currentCount - 1)
      if (newCount === 0) {
        this.badgeTarget.style.display = "none"
      } else {
        this.badgeTarget.textContent = newCount
      }
    }
  }

  prependNotification(html) {
    if (this.hasListTarget) {
      // Remove empty state if present
      const emptyState = this.listTarget.querySelector(".pf-empty-state")
      if (emptyState) {
        emptyState.remove()
      }

      // Add new notification at the top
      this.listTarget.insertAdjacentHTML("afterbegin", html)

      // Animate the new notification
      const newNotification = this.listTarget.firstElementChild
      if (newNotification) {
        newNotification.classList.add("pf-notification-new")
        setTimeout(() => {
          newNotification.classList.remove("pf-notification-new")
        }, 300)
      }
    }
  }

  markAsReadInUI(notificationId) {
    const notification = document.querySelector(`[data-notification-id="${notificationId}"]`)
    if (notification) {
      notification.classList.remove("pf-notification-unread")
    }
  }

  updateBadgeCount() {
    if (this.hasCountTarget && this.hasBadgeTarget) {
      const count = parseInt(this.countTarget.dataset.unreadCount) || 0
      if (count > 0) {
        this.badgeTarget.textContent = count > 99 ? "99+" : count
        this.badgeTarget.style.display = "flex"
      } else {
        this.badgeTarget.style.display = "none"
      }
    }
  }

  playNotificationSound() {
    // Optional: play a subtle notification sound
    // You can add an audio element and play it here
    // const audio = new Audio('/sounds/notification.mp3')
    // audio.volume = 0.3
    // audio.play().catch(() => {})
  }

  markAsRead(event) {
    const notificationId = event.currentTarget.dataset.notificationId
    if (!notificationId) return

    fetch(`/notifications/${notificationId}/mark_as_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      }
    }).then(response => {
      if (response.ok) {
        this.markAsReadInUI(notificationId)
        this.decrementBadge()
      }
    })
  }

  markAllAsRead() {
    fetch("/notifications/mark_all_as_read", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      }
    }).then(response => {
      if (response.ok) {
        document.querySelectorAll(".pf-notification-unread").forEach(el => {
          el.classList.remove("pf-notification-unread")
        })
        if (this.hasBadgeTarget) {
          this.badgeTarget.style.display = "none"
        }
      }
    })
  }

  toggleDropdown() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("show")
    }
  }
}
