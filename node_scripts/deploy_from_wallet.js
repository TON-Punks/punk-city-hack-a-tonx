import fs from 'fs'
// import compiler from "ton-compiler"
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton
// const { compileFift, compileFunc } = compiler;

// const source = fs.readFileSync("smart_contracts/rock-paper-scissors.fc").toString('utf-8');
// let fift = await compileFunc(source)
// let compiled = await compileFift(fift)
let compiledBoc = "b5ee9c7201020601000128000114ff00f4a413f4bcf2c80b0104ecd332d0d30331fa4030ed44d020db3c3708d30921a70322a70aaa005220d72229c0032ac004b1f2d06553a7c70553b7c705b1f2e06653a7c7052ac002b0f2d06753a6c7052ac001b0f2d068c829cf1628cf1627cf1616cb1f5240cb0752b0cb0729c000e3023a5b06c001306d7f7052098ae4345072be02030405001efa40fa40fa40d31fd307d307d30330005c6c33333434353566d701305024c7059d7258cb03541202cf017002cf019c7158cb03705112cf0101cf01e2c9ed54001c04d2095055a004d2095099a0080400989710235f033233749c6c1206be933273349130e203e258cb03c9ed54708010c8cb0558cf1603a75a8064a90413fa0212cb6ac9708010c8cb055003cf1622fa0212cb6ac90173fb008306fb00"
const compiled = Buffer.from(compiledBoc, 'hex')
// console.log(compiled.toString('hex'))

let codeCell = Cell.fromBoc(compiled)[0]

// Prepare State
let manager = Address.parse(process.env.MANAGER_ADDRESS)
let creator = Address.parse(process.env.CREATOR_ADDRESS)
let opponent = Address.parse(process.env.OPPONENT_ADDRESS)

let dataCell = new Cell();
dataCell.bits.writeAddress(manager);
dataCell.bits.writeAddress(creator);
dataCell.bits.writeAddress(opponent);
dataCell.bits.writeUint(parseInt(process.env.GAME_ID), 32);
dataCell.bits.writeUint(parseInt(process.env.CREATOR_HEALTH), 8);
dataCell.bits.writeUint(parseInt(process.env.OPPONENT_HEALTH), 8);
dataCell.bits.writeUint(0, 4);

const contractSource = {
  initialCode: codeCell,
  initialData: dataCell,
  workchain: 0,
  type: ''
}

const contract = contractAddress(contractSource)
console.log(`address: ${contract.toString()}`)
console.log(`base64_address: ${contract.toFriendly()}`)
let msgCell = new Cell()

const client = new TonClient({ endpoint: process.env.CLIENT_ENDPOINT, apiKey: process.env.CLIENT_API_KEY });

let secretKey = Buffer.from(process.env.MANAGER_SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.MANAGER_PUBLIC_KEY, 'hex')

const wallet_contract = WalletContract.create(client, WalletV3R2Source.create({ publicKey, workchain: 0}))
const contractMessage = new CommonMessageInfo({
  stateInit: new StateInit({ code: contractSource.initialCode, data: contractSource.initialData }),
  body: new CellMessage(msgCell)
})

const seqNo = await wallet_contract.getSeqNo()
const transfer = wallet_contract.createTransfer({
  secretKey: secretKey,
  seqno: seqNo,
  sendMode: 1,
  order: new InternalMessage({
      to: contract,
      value: toNano(0.005),
      bounce: false,
      body: contractMessage
  })
 })

if (process.env.DRY_RUN != 'true') {
  await client.sendExternalMessage(wallet_contract, transfer)
}
