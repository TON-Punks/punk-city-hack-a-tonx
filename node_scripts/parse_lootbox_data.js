import fs from 'fs'
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton

const data = process.env.MESSAGE_DATA;
const dataBuffer = Buffer.from(data, 'base64')
const compiled = Buffer.from(dataBuffer, 'hex')

let slice = Cell.fromBoc(compiled)[0].beginParse()

console.log(slice.readUint(32).toString()) //  Lootbox id
console.log(slice.readUint(8).toString()); // Chance:
console.log(slice.readUint(4).toString()); // Result:
console.log(slice.readUint(4).toString()); // Weapon Position
