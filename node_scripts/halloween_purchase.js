import Ton from 'ton'
const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source, EmptyMessage } = Ton

const client = new TonClient({
  endpoint: 'https://toncenter.com/api/v2/jsonRPC',
  apiKey: '9cecd4b376aa13928fb399b462ec1a80e7e9453fa56eabd277c6473568fc88db'
});

let secretKey = Buffer.from(process.env.SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.PUBLIC_KEY, 'hex')

let punk1 = Address.parse(process.env.PUNK1_ADDRESS)
let punk2 = Address.parse(process.env.PUNK2_ADDRESS)

let bodyCell = new Cell()
bodyCell.bits.writeAddress(punk1);
bodyCell.bits.writeAddress(punk2);

let toAddress = Address.parse(process.env.ADDRESS)
let withdrawEverything = process.env.EVERYTHING == 'true'
const wallet_contract = WalletContract.create(client, WalletV3R2Source.create({ publicKey, workchain: 0}))
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
