import fs from 'fs'
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton

const contract = Address.parse(process.env.CONTRACT_ADDRESS)

const client = new TonClient({ endpoint: process.env.CLIENT_ENDPOINT, apiKey: process.env.CLIENT_API_KEY });

let secretKey = Buffer.from(process.env.SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.PUBLIC_KEY, 'hex')

let top1 = Address.parse(process.env.TOP1_ADDRESS)
let top2 = Address.parse(process.env.TOP2_ADDRESS)
let top3 = Address.parse(process.env.TOP3_ADDRESS)

let bodyCell = new Cell()
bodyCell.bits.writeAddress(top1);
bodyCell.bits.writeAddress(top2);
bodyCell.bits.writeAddress(top3);

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
      value: toNano(0.01),
      bounce: true,
      body: contractMessage
  })
  })

  await client.sendExternalMessage(wallet_contract, transfer)
}
