import fs from 'fs'
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton

let compiledBoc = "b5ee9c720101060100bd000114ff00f4a413f4bcf2c80b01022cd332ed44d0db3c01d0d30331fa403001c705915be30d02030006fa403002fcdb3c30708010c8cb055004cf1623fa0213cb6ac9708010c8cb055003cf1624a7198064a904fa0212cb6ac9708010c8cb0524cf1625a70d8064a904fa02cb6ac9708010c8cb0525cf1626aa028064a904fa02cb6ac9708010c8cb055006cf1606aa018064a90416fa0214cb6ac970fb000370fb000170fb000170fb00830604050012fa40fa40fa40d430d00004fb00"
const compiled = Buffer.from(compiledBoc, 'hex')

let codeCell = Cell.fromBoc(compiled)[0]

// Prepare State
let manager = Address.parse(process.env.MANAGER_ADDRESS)

let dataCell = new Cell();
dataCell.bits.writeAddress(manager);

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
      value: toNano(0.01),
      bounce: false,
      body: contractMessage
  })
 })

if (process.env.DRY_RUN != 'true') {
  await client.sendExternalMessage(wallet_contract, transfer)
}
