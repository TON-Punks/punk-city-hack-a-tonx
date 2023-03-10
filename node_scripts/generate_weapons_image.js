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
context.textBaseline = 'top'
context.font = "13px 'PressStart'";

const data = JSON.parse(process.env.DATA)
const locale = data.locale

const weapon_images = data.weapon_images
const weapon_perks = data.weapon_perks

const drawWeaponImage = (path, x, y) => {
  if (path) {
    return loadImage(path).then((weaponImage) => {
      context.drawImage(weaponImage, x, y, 290, 277)
    })
  } else {
    Promise.resolve()
  }
}

const drawTextImage = (textPath) => {
  if (textPath) {
    return loadImage(textPath).then((perkImage) => {
      context.drawImage(perkImage, 0, 0)
    })
  } else {
    Promise.resolve()
  }
}

loadImage(`./telegram_assets/images/${locale}/rules_template.png`).then(image => {
    context.drawImage(image, 0, 0, width, height)

    Promise.all([
      drawTextImage(weapon_perks[1]),
      drawTextImage(weapon_perks[2]),
      drawTextImage(weapon_perks[3]),
      drawTextImage(weapon_perks[4]),
      drawTextImage(weapon_perks[5]),
      drawWeaponImage(weapon_images[1], 255, 232),
      drawWeaponImage(weapon_images[2], 581, 55),
      drawWeaponImage(weapon_images[3], 912, 232),
      drawWeaponImage(weapon_images[4], 831, 612),
      drawWeaponImage(weapon_images[5], 332, 612)
    ]).then(() => console.log(canvas.toDataURL()))
})
