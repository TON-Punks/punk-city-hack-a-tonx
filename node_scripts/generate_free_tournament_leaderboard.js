import Canvas from 'canvas';
const { registerFont, createCanvas, loadImage } = Canvas;
import fs from 'fs'

registerFont('./telegram_assets/fonts/PressStart2P-Regular.ttf', { family: 'PressStart'})

// Define the canvas
const width = 1440 // width of the image
const height = 960 // height of the image
const canvas = createCanvas(width, height)
const context = canvas.getContext('2d')

// Define color scheme
const dateColor = "#A73EE2"
const dateFadeColor = "#301D89"

const tableColor = "#0078FE"
const tableFadeColor = "#2E1D89"

const positionColor = "#21B4B1"

// Define the font style
context.textAlign = "center"
context.textBaseline = "top"
context.font = "36px 'PressStart'";

const out = fs.createWriteStream('./test.png')

const data = JSON.parse(process.env.DATA)

const locale = data.locale
const date = data.date
const usersData = data.users_data

const fillGlowingText = (text, coordinateX, coordinateY, fadeDelta, color, fadeColor) => {
  context.fillStyle = fadeColor
  context.fillText(text, coordinateX + fadeDelta, coordinateY + fadeDelta)

  context.fillStyle = color
  context.fillText(text, coordinateX, coordinateY)
}

// Load and draw the background image first
loadImage(`./telegram_assets/images/${locale}/free_tournaments/leaderboard.png`).then(image => {
    context.drawImage(image, 0, 0, width, height)

    // Tournament's date
    context.font = "36px 'PressStart'"
    context.textAlign = "center"
    fillGlowingText(date, 1160, 77, 5, dateColor, dateFadeColor)

    // Table
    context.textAlign = "left"
    usersData.forEach((item, i) => {
      context.textAlign = "center"
      fillGlowingText(item["position"], 114, 233 + i * 67, 3, positionColor, tableFadeColor)

      context.textAlign = "left"
      fillGlowingText(item["username"], 166, 233 + i * 67, 4, tableColor, tableFadeColor)
      fillGlowingText(item["score"], 636, 233 + i * 67, 4, tableColor, tableFadeColor)
      fillGlowingText(`${item["games_won"]}/${item["games_lost"]}`, 824 , 233 + i * 67, 4, tableColor, tableFadeColor)
      fillGlowingText(item["reward"], 1187, 233 + i * 67, 4, tableColor, tableFadeColor)
    });

    console.log(canvas.toDataURL())
})
