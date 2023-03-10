import Canvas from 'canvas';
const { createCanvas, loadImage } = Canvas;
import fs from 'fs'

// Define the canvas
const width = 1440 // width of the image
const height = 960 // height of the image
const canvas = createCanvas(width, height)
const context = canvas.getContext('2d')

const data = JSON.parse(process.env.DATA);

const locale = data.locale;
const image_url = data.image_url;
const template_path = data.template_path;
const out = fs.createWriteStream(data.output_path);

let loadedImage = await loadImage(image_url);

loadImage(template_path).then((image) => {
  context.drawImage(image, 0, 0, width, height);

  context.drawImage(loadedImage, 531, 171, 378, 363);

  const stream = canvas.createPNGStream();
  stream.pipe(out);
  out.on("finish", () => console.log("The PNG file was created."));
});
