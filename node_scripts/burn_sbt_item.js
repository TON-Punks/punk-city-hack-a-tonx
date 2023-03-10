import fs from 'fs'
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton

let address = Address.parse(process.env.CONTRACT_ADDRESS)

let bodyCell = new Cell();

bodyCell.bits.writeUint(520377210, 32) // Op Code
bodyCell.bits.writeUint(0, 64) // Query Id

const client = new TonClient({ endpoint: process.env.CLIENT_ENDPOINT, apiKey: process.env.CLIENT_API_KEY });

let secretKey = Buffer.from(process.env.SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.PUBLIC_KEY, 'hex')

const wallet_contract = WalletContract.create(client, WalletV3R2Source.create({ publicKey, workchain: 0}))
const contractMessage = new CommonMessageInfo({
  body: new CellMessage(bodyCell)
})

const seqNo = await wallet_contract.getSeqNo()
const transfer = wallet_contract.createTransfer({
  secretKey: secretKey,
  seqno: seqNo,
  sendMode: 1,
  order: new InternalMessage({
      to: address,
      value: toNano(0.05),
      bounce: false,
      body: contractMessage
  })
 })

await client.sendExternalMessage(wallet_contract, transfer)
