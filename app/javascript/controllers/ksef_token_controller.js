import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ksef-token"
export default class extends Controller {
  static targets = ["maskedRow","newTokenField" ]
  connect() {
  }

  changeToken() {
    this.maskedRowTarget.classList.add("hidden")
    this.newTokenFieldTarget.classList.remove("hidden")
    
    const textarea = this.newTokenFieldTarget.querySelector("textarea")
    if (textarea) textarea.focus()
  }

}