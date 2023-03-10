import Canvas from 'canvas';
const { registerFont, createCanvas, loadImage } = Canvas;
import fs from 'fs'

registerFont('./telegram_assets/fonts/PressStart2P-Regular.ttf', { family: 'PressStart'})

// Define the canvas
const width = 1440 // width of the image
const height = 960 // height of the image
const canvas = createCanvas(width, height)
const context = canvas.getContext('2d')

const primaryColor = "#0578FE"
const secondaryColor = "#02B3B1"

const successColor = "#07EBEB"
const dangerColor = "#FB31F6"

// Define the font style
context.textAlign = 'center'
context.textBaseline = 'top'
context.fillStyle = '#FFFFFF'
context.font = "26px 'PressStart'";

const out = fs.createWriteStream(process.env.OUTPUT_PATH)

const locale = process.env.LOCALE

const userImage = process.env.USER_IMAGE
const opponentImage = process.env.OPPONENT_IMAGE

const userName = process.env.USER_NAME
const opponentName = process.env.OPPONENT_NAME

const userLevel = process.env.USER_LVL
const opponentLevel = process.env.OPPONENT_LVL

const userWins = process.env.USER_WIN_COUNT
const opponentWins = process.env.OPPONENT_WIN_COUNT
const userWon = process.env.USER_WON == 'true'

const template = userWon ? 'results_win_template' : 'results_loss_template'

const scoreColor = userWon ? successColor : dangerColor
const scoreText = `${userWins}:${opponentWins}`

let loadedUserImage;
let loadedOpponentImage;

if (userImage) {
  loadedUserImage = await loadImage(userImage)
}

if (opponentImage) {
  loadedOpponentImage = await loadImage(opponentImage)
}

loadImage(`./telegram_assets/images/${locale}/${template}.png`).then(image => {
    context.drawImage(image, 0, 0, width, height)

    if (userImage) {
      context.drawImage(loadedUserImage, 190, 303, 357, 357)
    }

    if (opponentImage) {
      context.drawImage(loadedOpponentImage, 894, 303, 357, 357)
    }

    // Draw user & opponent names
    context.fillStyle = primaryColor
    context.fillText(userName, 364, 718)
    context.fillText(opponentName, 1076, 718)

    // Draw user & opponent levels
    context.fillStyle = secondaryColor
    context.fillText(userLevel, 364, 748)
    context.fillStyle = primaryColor
    context.fillText(opponentLevel, 1076, 748)

    // Draw score 1:2
    context.fillStyle = successColor
    context.fillText(scoreText, 727, 566)

    const stream = canvas.createPNGStream()
    stream.pipe(out)
    out.on('finish', () =>  console.log('The PNG file was created.'))
})
