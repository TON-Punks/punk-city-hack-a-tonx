import Canvas from 'canvas';
const { registerFont, createCanvas, loadImage } = Canvas;
import fs from 'fs'

registerFont('./telegram_assets/fonts/PressStart2P-Regular.ttf', { family: 'PressStart'})

// Define the canvas
const width = 1440 // width of the image
const height = 960 // height of the image
const canvas = createCanvas(width, height)
const context = canvas.getContext('2d')

// Define the font style

const out = fs.createWriteStream(process.env.OUTPUT_PATH)

const locale = process.env.LOCALE

const move1 = process.env.MOVE_1
const move2 = process.env.MOVE_2
const firstPersonImage = process.env.FIRST_PERSON_IMAGE_PATH
const secondPersonImage = process.env.SECOND_PERSON_IMAGE_PATH

let loadedfirstPersonImage;
let loadedsecondPersonImage;

if (firstPersonImage) {
  loadedfirstPersonImage = await loadImage(firstPersonImage)
}

if (secondPersonImage) {
  loadedsecondPersonImage = await loadImage(secondPersonImage)
}

loadImage(`./telegram_assets/images/${locale}/${move1}_${move2}.png`).then(image => {
    context.drawImage(image, 0, 0, width, height)

    if (firstPersonImage) {
      context.drawImage(loadedfirstPersonImage, 141, 312, 478, 457)
    }

    if (secondPersonImage) {
      context.drawImage(loadedsecondPersonImage, 820, 303, 478, 457)
    }

    const stream = canvas.createPNGStream()
    stream.pipe(out)
    out.on('finish', () =>  console.log('The PNG file was created.'))
})
