import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

// Messages Controller
// Handles real-time messaging functionality
export default class extends Controller {
  static targets = ["messagesContainer", "form", "input", "sendBtn", "typingIndicator"]
  static values = {
    conversationId: Number
  }

  connect() {
    this.scrollToBottom()
    this.subscribeToChannel()
    this.typingTimeout = null
    this.isTyping = false
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }
  }

  // Subscribe to ActionCable channel
  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "ConversationChannel" },
      {
        connected: () => {
          console.log("Connected to ConversationChannel")
        },
        disconnected: () => {
          console.log("Disconnected from ConversationChannel")
        },
        received: (data) => {
          this.handleReceived(data)
        }
      }
    )
  }

  // Handle received messages
  handleReceived(data) {
    if (data.conversation_id !== this.conversationIdValue) return

    switch (data.type) {
      case 'new_message':
        this.appendMessage(data.message)
        break
      case 'typing':
        this.showTypingIndicator(data.user)
        break
      case 'stop_typing':
        this.hideTypingIndicator()
        break
    }
  }

  // Append new message to chat
  appendMessage(message) {
    const container = this.messagesContainerTarget
    const messageHtml = this.createMessageHtml(message)
    container.insertAdjacentHTML('beforeend', messageHtml)
    this.scrollToBottom()
    this.hideTypingIndicator()
  }

  // Create message HTML
  createMessageHtml(message) {
    const isOwn = false // Received messages are never own
    return `
      <div class="pf-message" id="message_${message.id}">
        <img src="${message.sender.profile_pic || '/assets/user-pp.png'}" class="pf-message-avatar" alt="">
        <div class="pf-message-content">
          <div class="pf-message-bubble">
            <p>${this.escapeHtml(message.body)}</p>
          </div>
          <span class="pf-message-time">${this.formatTime(message.created_at)}</span>
        </div>
      </div>
    `
  }

  // Send message
  send(event) {
    event.preventDefault()

    const input = this.inputTarget
    const body = input.value.trim()

    if (!body) return

    // Submit form
    this.formTarget.requestSubmit()

    // Clear input and reset
    input.value = ''
    this.updateSendButton()
    this.stopTypingNotification()

    // Add optimistic message
    this.addOptimisticMessage(body)
  }

  // Add optimistic message (before server confirms)
  addOptimisticMessage(body) {
    const container = this.messagesContainerTarget
    const tempId = `temp_${Date.now()}`

    const messageHtml = `
      <div class="pf-message pf-message-own pf-message-sending" id="${tempId}">
        <div class="pf-message-content">
          <div class="pf-message-bubble">
            <p>${this.escapeHtml(body)}</p>
          </div>
          <span class="pf-message-time">Sending...</span>
        </div>
      </div>
    `

    container.insertAdjacentHTML('beforeend', messageHtml)
    this.scrollToBottom()
  }

  // Handle typing
  typing() {
    const hasContent = this.inputTarget.value.trim().length > 0
    this.updateSendButton()

    if (hasContent && !this.isTyping) {
      this.sendTypingNotification()
    }

    // Clear previous timeout
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }

    // Stop typing after 2 seconds of inactivity
    this.typingTimeout = setTimeout(() => {
      this.stopTypingNotification()
    }, 2000)
  }

  // Send typing notification
  sendTypingNotification() {
    if (this.subscription) {
      this.subscription.perform('typing', { conversation_id: this.conversationIdValue })
      this.isTyping = true
    }
  }

  // Stop typing notification
  stopTypingNotification() {
    if (this.subscription && this.isTyping) {
      this.subscription.perform('stop_typing', { conversation_id: this.conversationIdValue })
      this.isTyping = false
    }
  }

  // Show typing indicator
  showTypingIndicator(user) {
    if (this.hasTypingIndicatorTarget) {
      this.typingIndicatorTarget.style.display = 'flex'
      this.scrollToBottom()
    }
  }

  // Hide typing indicator
  hideTypingIndicator() {
    if (this.hasTypingIndicatorTarget) {
      this.typingIndicatorTarget.style.display = 'none'
    }
  }

  // Update send button visibility
  updateSendButton() {
    if (this.hasSendBtnTarget) {
      const hasContent = this.inputTarget.value.trim().length > 0
      this.sendBtnTarget.style.display = hasContent ? 'block' : 'none'
    }
  }

  // Scroll to bottom of messages
  scrollToBottom() {
    if (this.hasMessagesContainerTarget) {
      const container = this.messagesContainerTarget
      container.scrollTop = container.scrollHeight
    }
  }

  // Format time
  formatTime(dateString) {
    const date = new Date(dateString)
    return date.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
