import fs from 'fs'
// import compiler from "ton-compiler"
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton


const contract = Address.parse(process.env.CONTRACT_ADDRESS)


const client = new TonClient({ endpoint: process.env.CLIENT_ENDPOINT, apiKey: process.env.CLIENT_API_KEY });

let secretKey = Buffer.from(process.env.SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.PUBLIC_KEY, 'hex')

let bodyCell = new Cell()

bodyCell.bits.writeUint(parseInt(process.env.GAME_ROUNDS), 10)

const gameMoves = process.env.GAME_MOVES;
const damages = process.env.DAMAGES.split(',');

[...gameMoves].forEach((move) => {
  bodyCell.bits.writeUint(parseInt(move), 3)
});

[...damages].forEach((damage) => {
  bodyCell.bits.writeInt(parseInt(damage), 10)
});


const wallet_contract = WalletContract.create(client, WalletV3R2Source.create({ publicKey, workchain: 0}))
const contractMessage = new CommonMessageInfo({
  body: new CellMessage(bodyCell)
})

if (process.env.DRY_RUN != 'true') {
  const seqNo = await wallet_contract.getSeqNo()
  const transfer = wallet_contract.createTransfer({
  secretKey: secretKey,
  seqno: seqNo,
  sendMode: 0,
  order: new InternalMessage({
      to: contract,
      value: parseInt(process.env.BET_VALUE),
      bounce: true,
      body: contractMessage
  })
  })

  await client.sendExternalMessage(wallet_contract, transfer)
}
