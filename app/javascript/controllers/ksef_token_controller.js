import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ksef-token"
export default class extends Controller {
  static targets = ["maskedRow","newTokenField", "testButton" ]
  connect() {
  }

  changeToken() {
    this.maskedRowTarget.classList.add("hidden")
    this.newTokenFieldTarget.classList.remove("hidden")
    
    const textarea = this.newTokenFieldTarget.querySelector("textarea")
    if (textarea) textarea.focus()
  }

  async testToken() {
    // const button = this.element.querySelector('[data-action="click->ksef-token#testToken"]')
    const button = this.testButtonTarget;
    if (!button) return

    const originalText = button.textContent

    button.disabled = true
    button.textContent = "Testuję..."

    try {
      const response = await fetch('/account/settings/ksef/test_token', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      })

      const data = await response.json()

      if (data.success) {
        alert(data.message || "✅ Token jest poprawny!")
      } else {
        alert(data.message || "❌ Błąd podczas testowania tokenu")
      }
    } catch (error) {
      alert("Wystąpił błąd podczas łączenia z serwerem")
      console.error(error)
    } finally {
      button.disabled = false
      button.textContent = originalText
    }
  }

}