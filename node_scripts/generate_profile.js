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
const primaryColor = "#0578FE"
const secondaryColor = "#666BFF"

const successColor = "#07EBEB"
const dangerColor = "#FB31F6"

const fadedSuccessColor = "#02B3B1"
const fadedDangerColor = "#A73EE2"

// Define the font style
context.textAlign = 'center'
context.textBaseline = 'top'
context.font = "32px 'PressStart'";

const out = fs.createWriteStream('./test.png')

const data = JSON.parse(process.env.DATA)

const locale = data.locale
const identification = data.identification
const gamesCount = data.games_count
const winsCount = data.wins
const winsLabel = data.wins_label
const losesCount = data.loses
const losesLabel = data.loses_label
const level = data.level
const tonWon = data.ton_won
const tonLost = data.ton_lost
const punkUrl = data.punk_url

let circleImage;

if (gamesCount > 0) {
  const circleNumber = Math.round(winsCount / gamesCount * 100 / 5) * 5; // round to nearest 5
  circleImage = await loadImage(`./telegram_assets/images/profile/win_loose_circles/${circleNumber}.png`);
}

const drawTonStats = (text, textColor, coordinateX) => {
  context.font = "42px 'PressStart'"
  context.fillStyle = textColor
  context.textAlign = "center"
  context.fillText(text, coordinateX, 694)
}

const drawWinLoseStats = (textCount, textCaption, textColor, fadedTextColor, coordinateY) => {
  context.font = "31px 'PressStart'"
  context.fillStyle = textColor
  context.textAlign = "left"
  context.fillText(textCount, 855, coordinateY)

  context.fillStyle = fadedTextColor
  context.fillText(textCaption, 855 + context.measureText(textCount).width + 43, coordinateY)
}

// Load and draw the background image first
loadImage(`./telegram_assets/images/${locale}/profile_template.png`).then(image => {
    context.drawImage(image, 0, 0, width, height)

    // Punk Number (TON PUNK #12)
    context.font = "28px 'PressStart'"
    context.fillStyle = primaryColor
    context.fillText(identification, 384, 622)

    // Level (LVL 30)
    context.font = "28px 'PressStart'"
    context.fillStyle = primaryColor
    context.fillText(level, 384, 672)

    // TON WON (500 💎)
    drawTonStats(tonWon, successColor, 834)

    // TON LOST (300 💎)
    drawTonStats(tonLost, dangerColor, 1174)

    // WINS (76 WINS)
    drawWinLoseStats(winsCount, winsLabel, successColor, fadedSuccessColor, 422)

    // LOST (30 LOSES)
    drawWinLoseStats(losesCount, losesLabel, dangerColor, fadedDangerColor, 495)

    // WINS/LOSES Circle (Percentage)
    if (gamesCount > 0) {
      context.drawImage(circleImage, 718, 423, 103, 103)
    }

    if (punkUrl) {
        loadImage(punkUrl).then(punkImage => {
            context.shadowBlur = 0;
            context.drawImage(punkImage, 222, 240, 325, 325)
            console.log(canvas.toDataURL())
        })
    } else {
        console.log(canvas.toDataURL())
    }
})
