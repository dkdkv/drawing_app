// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.Canvas = {
  mounted() {
    this.canvas = this.el.getContext('2d')
    this.isDrawing = false
    this.x = 0
    this.y = 0

    this.el.addEventListener('mousedown', (e) => this.startDrawing(e))
    this.el.addEventListener('mousemove', (e) => this.draw(e))
    this.el.addEventListener('mouseup', () => this.stopDrawing())
    this.el.addEventListener('mouseout', () => this.stopDrawing())

    this.handleEvent("init_canvas", ({data}) => {
      if (data) {
        let image = new Image()
        image.onload = () => {
          this.canvas.clearRect(0, 0, this.el.width, this.el.height)
          this.canvas.drawImage(image, 0, 0)
        }
        image.src = data
      }
    })

    this.el.addEventListener('mousemove', (e) => {
      const rect = this.el.getBoundingClientRect()
      const x = e.clientX - rect.left
      const y = e.clientY - rect.top
      this.pushEvent("cursor_moved", { x, y })
    })

    window.addEventListener('beforeunload', () => {
      this.pushEvent("cursor_left", {})
    })

    this.handleEvent("cursor_moved", ({ user, x, y }) => {
      let cursor = document.getElementById(`cursor-${user}`)
      if (!cursor) {
        cursor = document.createElement('div')
        cursor.id = `cursor-${user}`
        cursor.className = 'absolute pointer-events-none'
        cursor.innerHTML = `
          <div class="w-3 h-3 bg-red-500 rounded-full"></div>
          <span class="text-xs bg-white px-1 rounded">${user}</span>
        `
        this.el.parentNode.appendChild(cursor)
      }
      cursor.style.left = `${x}px`
      cursor.style.top = `${y}px`
    })

    this.handleEvent("cursor_left", ({ user }) => {
      const cursor = document.getElementById(`cursor-${user}`)
      if (cursor) {
        cursor.remove()
      }
    })

    this.handleEvent("update_canvas", ({data}) => {
      let image = new Image()
      image.onload = () => {
        this.canvas.clearRect(0, 0, this.el.width, this.el.height)
        this.canvas.drawImage(image, 0, 0)
      }
      image.onerror = (error) => {
        console.error("Error loading image:", error)
      }
      image.src = data
    })

  // Запрашиваем начальное состояние при подключении
  this.pushEvent("get_initial_state", {}, (reply) => {
    if (reply.data) {
      let image = new Image()
      image.onload = () => {
        this.canvas.clearRect(0, 0, this.el.width, this.el.height)
        this.canvas.drawImage(image, 0, 0)
      }
      image.src = reply.data
    }
  })
},

  startDrawing(event) {
    this.isDrawing = true;
    [this.x, this.y] = [event.offsetX, event.offsetY]
  },

  stopDrawing() {
    this.isDrawing = false
    this.pushEvent("draw", { data: this.el.toDataURL() })
  },

  draw(event) {
    if (!this.isDrawing) return

    this.canvas.beginPath()
    this.canvas.moveTo(this.x, this.y)
    this.canvas.lineTo(event.offsetX, event.offsetY)
    this.canvas.stroke()

    this.x = event.offsetX
    this.y = event.offsetY
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket