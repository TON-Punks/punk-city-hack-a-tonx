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

// Define the font style
context.textAlign = 'center'
context.textBaseline = 'top'
context.fillStyle = '#FFFFFF'
context.font = "26px 'PressStart'";

const out = fs.createWriteStream(process.env.OUTPUT_PATH)

const locale = process.env.LOCALE

const creatorImage = process.env.CREATOR_IMAGE
const opponentImage = process.env.OPPONENT_IMAGE

const creatorName = process.env.CREATOR_NAME
const opponentName = process.env.OPPONENT_NAME

const creatorLevel = process.env.CREATOR_LVL
const opponentLevel = process.env.OPPONENT_LVL

let loadedCreatorImage;
let loadedOpponentImage;

if (creatorImage) {
  loadedCreatorImage = await loadImage(creatorImage)
}

if (opponentImage) {
  loadedOpponentImage = await loadImage(opponentImage)
}

loadImage(`./telegram_assets/images/${locale}/versus.png`).then(image => {
    context.drawImage(image, 0, 0, width, height)

    if (creatorImage) {
      context.drawImage(loadedCreatorImage, 190, 303, 357, 357)
    }

    if (opponentImage) {
      context.drawImage(loadedOpponentImage, 894, 303, 357, 357)
    }

    context.fillStyle = primaryColor
    context.fillText(creatorName, 364, 718)
    context.fillText(opponentName, 1076, 718)

    context.fillStyle = secondaryColor
    context.fillText(creatorLevel, 364, 748)

    context.fillStyle = primaryColor
    context.fillText(opponentLevel, 1076, 748)

    const stream = canvas.createPNGStream()
    stream.pipe(out)
    out.on('finish', () =>  console.log('The PNG file was created.'))
})
