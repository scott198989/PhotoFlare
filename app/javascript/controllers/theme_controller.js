import { Controller } from "@hotwired/stimulus"

// Theme Controller
// Handles light/dark theme switching with smooth transitions
// Persists preference to localStorage and optionally to user's DB record
export default class extends Controller {
  static targets = ["toggle", "icon", "label"]
  static values = {
    theme: { type: String, default: "light" },
    saveUrl: String  // Optional: URL to persist theme preference
  }

  connect() {
    this.loadTheme()
    this.bindSystemPreference()
  }

  // Load theme from localStorage or system preference
  loadTheme() {
    const savedTheme = localStorage.getItem('pf-theme')

    if (savedTheme) {
      this.themeValue = savedTheme
    } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      this.themeValue = 'dark'
    } else {
      this.themeValue = 'light'
    }

    this.applyTheme(this.themeValue)
  }

  // Listen for system preference changes
  bindSystemPreference() {
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        // Only auto-switch if user hasn't set a preference
        if (!localStorage.getItem('pf-theme')) {
          this.themeValue = e.matches ? 'dark' : 'light'
          this.applyTheme(this.themeValue)
        }
      })
    }
  }

  // Toggle between light and dark themes
  toggle() {
    const newTheme = this.themeValue === 'dark' ? 'light' : 'dark'
    this.themeValue = newTheme
    this.applyTheme(newTheme)
    this.saveTheme(newTheme)
    this.animateToggle()
  }

  // Apply theme to document
  applyTheme(theme) {
    // Add transitioning class for smooth animations
    document.documentElement.classList.add('theme-transitioning')

    // Set the theme attribute
    document.documentElement.setAttribute('data-theme', theme)

    // Update meta theme-color for mobile browsers
    const metaThemeColor = document.querySelector('meta[name="theme-color"]')
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', theme === 'dark' ? '#0f172a' : '#ffffff')
    }

    // Update icon if target exists
    this.updateIcon(theme)

    // Update label if target exists
    this.updateLabel(theme)

    // Remove transitioning class after animation completes
    setTimeout(() => {
      document.documentElement.classList.remove('theme-transitioning')
    }, 300)
  }

  // Save theme preference
  saveTheme(theme) {
    // Save to localStorage
    localStorage.setItem('pf-theme', theme)

    // Optionally save to database if URL is provided
    if (this.hasSaveUrlValue && this.saveUrlValue) {
      this.saveToDatabase(theme)
    }
  }

  // Save theme preference to database
  async saveToDatabase(theme) {
    try {
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content

      await fetch(this.saveUrlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ user: { theme_preference: theme } })
      })
    } catch (error) {
      console.warn('Could not save theme preference to database:', error)
    }
  }

  // Update the toggle icon
  updateIcon(theme) {
    if (this.hasIconTarget) {
      // Clear existing classes
      this.iconTarget.className = ''

      // Set new icon based on theme
      if (theme === 'dark') {
        this.iconTarget.className = 'fa-solid fa-moon'
      } else {
        this.iconTarget.className = 'fa-solid fa-sun'
      }
    }
  }

  // Update accessibility label
  updateLabel(theme) {
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'
    }

    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute('aria-label',
        theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'
      )
    }
  }

  // Animate the toggle button
  animateToggle() {
    if (this.hasIconTarget) {
      // Add spin animation
      this.iconTarget.classList.add('animate-spin')

      // Remove after animation completes
      setTimeout(() => {
        this.iconTarget.classList.remove('animate-spin')
      }, 300)
    }
  }

  // Get current theme
  get currentTheme() {
    return this.themeValue
  }

  // Check if dark mode is active
  get isDark() {
    return this.themeValue === 'dark'
  }

  // Check if light mode is active
  get isLight() {
    return this.themeValue === 'light'
  }
}
