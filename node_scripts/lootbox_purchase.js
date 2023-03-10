import Ton from 'ton'
const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source, EmptyMessage } = Ton

const client = new TonClient({ endpoint: process.env.CLIENT_ENDPOINT, apiKey: process.env.CLIENT_API_KEY });

let secretKey = Buffer.from(process.env.SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.PUBLIC_KEY, 'hex')

let lootboxId = process.env.LOOTBOX_ID

let bodyCell = new Cell()
bodyCell.bits.writeUint(lootboxId, 32);

let toAddress = Address.parse(process.env.ADDRESS)
let withdrawEverything = process.env.EVERYTHING == 'true'
const wallet_contract = WalletContract.create(client, WalletV3R2Source.create({ publicKey, workchain: 0 }))
const contractMessage = new CommonMessageInfo({
  body: new CellMessage(bodyCell)
})

const sendMode = withdrawEverything ? 128 : 0
const value = withdrawEverything ? 0 : parseInt(process.env.NANO_VALUE)

const seqNo = await wallet_contract.getSeqNo()
const transfer = wallet_contract.createTransfer({
  secretKey: secretKey,
  seqno: seqNo,
  sendMode: sendMode,
  order: new InternalMessage({
      to: toAddress,
      value: value,
      bounce: true,
      body: contractMessage
  })
 })

const result = await client.sendExternalMessage(wallet_contract, transfer)
console.log(result)
