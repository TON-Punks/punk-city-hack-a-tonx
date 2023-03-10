import * as fs from 'fs';

import { compileFunc, compileFift } from "tonc";

const source = fs.readFileSync(process.env.CONTRACT_LOCATION).toString('utf-8');
let compiled = await compileFunc(source)
let cell = await compileFift(compiled)

console.log(cell.toString('hex'));
