import { Controller } from "@hotwired/stimulus"

// Story Viewer Controller
// Handles the full-screen story viewing experience
export default class extends Controller {
  static targets = [
    "viewer", "content", "progressContainer",
    "avatar", "username", "time",
    "image", "video", "pauseBtn", "muteBtn",
    "replyInput"
  ]

  static values = {
    duration: { type: Number, default: 5000 } // 5 seconds per story
  }

  connect() {
    this.currentUserIndex = 0
    this.currentStoryIndex = 0
    this.users = []
    this.isPaused = false
    this.isMuted = true
    this.progressInterval = null

    // Keyboard navigation
    this.boundKeyHandler = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundKeyHandler)
  }

  disconnect() {
    this.stopProgress()
    document.removeEventListener('keydown', this.boundKeyHandler)
  }

  // Open story viewer from a story bubble
  open(event) {
    const bubble = event.currentTarget
    const userId = bubble.dataset.userId
    const username = bubble.dataset.username
    const profilePic = bubble.dataset.profilePic
    const stories = JSON.parse(bubble.dataset.stories || '[]')

    if (stories.length === 0) return

    // Collect all users with stories for navigation
    this.collectAllUsers()

    // Find the user index
    this.currentUserIndex = this.users.findIndex(u => u.userId === userId)
    if (this.currentUserIndex === -1) {
      this.currentUserIndex = 0
      this.users.unshift({ userId, username, profilePic, stories })
    }

    // Find first unviewed story or start from beginning
    const currentUser = this.users[this.currentUserIndex]
    this.currentStoryIndex = currentUser.stories.findIndex(s => !s.viewed)
    if (this.currentStoryIndex === -1) this.currentStoryIndex = 0

    // Show the viewer
    this.showViewer()
    this.displayCurrentStory()
  }

  // Collect all story users from the page
  collectAllUsers() {
    this.users = []
    document.querySelectorAll('[data-action*="story-viewer#open"]').forEach(bubble => {
      const userId = bubble.dataset.userId
      const username = bubble.dataset.username
      const profilePic = bubble.dataset.profilePic
      const stories = JSON.parse(bubble.dataset.stories || '[]')

      if (stories.length > 0 && !this.users.find(u => u.userId === userId)) {
        this.users.push({ userId, username, profilePic, stories })
      }
    })
  }

  // Show the viewer overlay
  showViewer() {
    this.viewerTarget.classList.add('active')
    document.body.style.overflow = 'hidden'
  }

  // Hide the viewer overlay
  close() {
    this.viewerTarget.classList.remove('active')
    document.body.style.overflow = ''
    this.stopProgress()
  }

  // Display the current story
  displayCurrentStory() {
    const user = this.users[this.currentUserIndex]
    if (!user) return this.close()

    const story = user.stories[this.currentStoryIndex]
    if (!story) return this.nextUser()

    // Update user info
    if (this.hasAvatarTarget) {
      this.avatarTarget.src = user.profilePic || '/assets/user-pp.png'
    }
    if (this.hasUsernameTarget) {
      this.usernameTarget.textContent = user.username
    }
    if (this.hasTimeTarget) {
      this.timeTarget.textContent = this.formatTimeAgo(story.created_at)
    }

    // Update progress bars
    this.updateProgressBars(user.stories.length, this.currentStoryIndex)

    // Display media
    const mediaUrl = story.media
    const isVideo = mediaUrl.includes('.mp4') || mediaUrl.includes('.webm') || mediaUrl.includes('.mov')

    if (isVideo) {
      this.showVideo(mediaUrl)
    } else {
      this.showImage(mediaUrl)
    }

    // Mark as viewed
    this.markAsViewed(story.id)

    // Start progress
    this.startProgress()
  }

  // Show image
  showImage(url) {
    if (this.hasImageTarget) {
      this.imageTarget.src = url
      this.imageTarget.style.display = 'block'
    }
    if (this.hasVideoTarget) {
      this.videoTarget.style.display = 'none'
      this.videoTarget.pause()
    }
  }

  // Show video
  showVideo(url) {
    if (this.hasImageTarget) {
      this.imageTarget.style.display = 'none'
    }
    if (this.hasVideoTarget) {
      this.videoTarget.src = url
      this.videoTarget.style.display = 'block'
      this.videoTarget.muted = this.isMuted
      this.videoTarget.play()
    }
  }

  // Update progress bars
  updateProgressBars(total, current) {
    if (!this.hasProgressContainerTarget) return

    this.progressContainerTarget.innerHTML = ''

    for (let i = 0; i < total; i++) {
      const bar = document.createElement('div')
      bar.className = 'pf-story-progress-bar'

      const fill = document.createElement('div')
      fill.className = 'pf-story-progress-fill'

      if (i < current) {
        fill.style.width = '100%'
      } else if (i === current) {
        fill.classList.add('active')
      }

      bar.appendChild(fill)
      this.progressContainerTarget.appendChild(bar)
    }
  }

  // Start progress animation
  startProgress() {
    this.stopProgress()

    const progressFill = this.progressContainerTarget.querySelector('.pf-story-progress-fill.active')
    if (!progressFill) return

    let progress = 0
    const duration = this.durationValue
    const interval = 50 // Update every 50ms

    this.progressInterval = setInterval(() => {
      if (this.isPaused) return

      progress += (interval / duration) * 100
      progressFill.style.width = `${Math.min(progress, 100)}%`

      if (progress >= 100) {
        this.next()
      }
    }, interval)
  }

  // Stop progress animation
  stopProgress() {
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
      this.progressInterval = null
    }
  }

  // Go to next story
  next() {
    this.stopProgress()

    const user = this.users[this.currentUserIndex]
    if (!user) return this.close()

    if (this.currentStoryIndex < user.stories.length - 1) {
      this.currentStoryIndex++
      this.displayCurrentStory()
    } else {
      this.nextUser()
    }
  }

  // Go to previous story
  prev() {
    this.stopProgress()

    if (this.currentStoryIndex > 0) {
      this.currentStoryIndex--
      this.displayCurrentStory()
    } else {
      this.prevUser()
    }
  }

  // Go to next user's stories
  nextUser() {
    this.stopProgress()

    if (this.currentUserIndex < this.users.length - 1) {
      this.currentUserIndex++
      this.currentStoryIndex = 0
      this.displayCurrentStory()
    } else {
      this.close()
    }
  }

  // Go to previous user's stories
  prevUser() {
    this.stopProgress()

    if (this.currentUserIndex > 0) {
      this.currentUserIndex--
      const user = this.users[this.currentUserIndex]
      this.currentStoryIndex = user.stories.length - 1
      this.displayCurrentStory()
    }
  }

  // Handle tap on story (left side = prev, right side = next)
  handleTap(event) {
    const rect = event.currentTarget.getBoundingClientRect()
    const x = event.clientX - rect.left
    const third = rect.width / 3

    if (x < third) {
      this.prev()
    } else if (x > third * 2) {
      this.next()
    }
  }

  // Toggle pause
  togglePause() {
    this.isPaused = !this.isPaused

    if (this.hasPauseBtnTarget) {
      const icon = this.pauseBtnTarget.querySelector('i')
      if (icon) {
        icon.className = this.isPaused ? 'fa-solid fa-play' : 'fa-solid fa-pause'
      }
    }

    if (this.hasVideoTarget && this.videoTarget.style.display !== 'none') {
      if (this.isPaused) {
        this.videoTarget.pause()
      } else {
        this.videoTarget.play()
      }
    }
  }

  // Toggle mute
  toggleMute() {
    this.isMuted = !this.isMuted

    if (this.hasMuteBtnTarget) {
      const icon = this.muteBtnTarget.querySelector('i')
      if (icon) {
        icon.className = this.isMuted ? 'fa-solid fa-volume-xmark' : 'fa-solid fa-volume-high'
      }
    }

    if (this.hasVideoTarget) {
      this.videoTarget.muted = this.isMuted
    }
  }

  // Keyboard navigation
  handleKeydown(event) {
    if (!this.viewerTarget.classList.contains('active')) return

    switch (event.key) {
      case 'ArrowLeft':
        this.prev()
        break
      case 'ArrowRight':
        this.next()
        break
      case 'Escape':
        this.close()
        break
      case ' ':
        event.preventDefault()
        this.togglePause()
        break
    }
  }

  // Mark story as viewed
  async markAsViewed(storyId) {
    try {
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content
      await fetch(`/stories/${storyId}/view`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        }
      })
    } catch (error) {
      console.warn('Could not mark story as viewed:', error)
    }
  }

  // Format time ago
  formatTimeAgo(dateString) {
    const date = new Date(dateString)
    const now = new Date()
    const seconds = Math.floor((now - date) / 1000)

    if (seconds < 60) return 'Just now'
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m`
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h`
    return `${Math.floor(seconds / 86400)}d`
  }
}
