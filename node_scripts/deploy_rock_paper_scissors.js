import fs from 'fs'
import compiler from "ton-compiler"
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache } = Ton
const { compileFift, compileFunc } = compiler;

const cache = new InMemoryCache()
const api = new HttpApi('https://toncenter.com/api/v2/jsonRPC', cache, {
  apiKey: '9cecd4b376aa13928fb399b462ec1a80e7e9453fa56eabd277c6473568fc88db',
})

const source = fs.readFileSync("/Users/thesmartnik/Documents/projects/side/tonpunk_contracts/rock-paper-scissors-one-off.func").toString('utf-8');
let fift = await compileFunc(source)
let compiled = await compileFift(fift)
let codeCell = Cell.fromBoc(compiled)[0]

// Prepare State
let owner = Address.parse('EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t')
let opponent = Address.parse('0QAs9VlT6S776tq3unJcP5Ogsj-ELLunLXuOb1EKcOQi4-QO')
let manager = Address.parse('EQDR4neQzqkfEz0oR3hXBcJph64d5NddP8H8wfN0thQIAqDH')

// let deployTo = Address.parse('EQDc4urcF3FLtPA_FW5bzHolzg5-NvybToe99xNf8hsvOhR5')

let dataCell = new Cell();
dataCell.bits.writeAddress(manager);
dataCell.bits.writeAddress(owner);
dataCell.bits.writeAddress(opponent);
dataCell.bits.writeUint(0, 3 + 2 + 2)

const contractSource = {
  initialCode: codeCell,
  initialData: dataCell,
  workchain: 0,
  type: ''
}

const address = contractAddress(contractSource)
console.log(`address: ${address.toString(false)}`)

let msgCell = new Cell()
// msgCell.bits.writeUint(0, 1)

const message = new ExternalMessage({
  to: address,
  body: new CommonMessageInfo({
      stateInit: new StateInit({ code: contractSource.initialCode, data: contractSource.initialData }),
      body: new CellMessage(msgCell)
  })
});


const cell = new Cell();
message.writeTo(cell);
const boc = cell.toBoc({ idx: false })

api.sendBoc(boc).then((r) => console.log(r))

