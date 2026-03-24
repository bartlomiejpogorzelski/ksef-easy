// app/javascript/controllers/file_preview_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]

  connect() {
    // Jeśli przy edycji już jest plik
    const input = this.element.querySelector("input[type='file']")
    if (input && input.files.length > 0) {
      this.updateDisplay()
    }
  }

  updateDisplay() {
    const input = this.element.querySelector("input[type='file']")
    const display = this.displayTarget

    if (input.files && input.files[0]) {
      display.textContent = input.files[0].name
      display.classList.add("text-indigo-600", "font-medium")
    } else {
      display.textContent = "Kliknij lub przeciągnij plik tutaj"
      display.classList.remove("text-indigo-600", "font-medium")
    }
  }
}