import fs from 'fs'
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton

const OFF_CHAIN_CONTENT_PREFIX = 0x01;

function bufferToChunks(buff, chunkSize) {
    let chunks = []
    while (buff.byteLength > 0) {
        chunks.push(buff.slice(0, chunkSize))
        buff = buff.slice(chunkSize)
    }
    return chunks
}

function makeSnakeCell(data) {
    let chunks = bufferToChunks(data, 127)
    let rootCell = new Cell()
    let curCell = rootCell

    for (let i = 0; i < chunks.length; i++) {
        let chunk = chunks[i]

        curCell.bits.writeBuffer(chunk)

        if (chunks[i+1]) {
            let nextCell = new Cell()
            curCell.refs.push(nextCell)
            curCell = nextCell
        }
    }

    return rootCell
}

function encodeOffChainContent(content) {
  let data = Buffer.from(content)
  let offChainPrefix = Buffer.from([OFF_CHAIN_CONTENT_PREFIX])
  data = Buffer.concat([offChainPrefix, data])
  return makeSnakeCell(data)
}

let ownerAddress = Address.parse(process.env.OWNER_ADDRESS)
let authorityAddress = Address.parse(process.env.EDITOR_ADDRESS)
let contract = Address.parse(process.env.COLLECTION_ADDRESS)

let bodyCell = new Cell();

bodyCell.bits.writeUint(1, 32) // Op Code
bodyCell.bits.writeUint(0, 64) // Query Id
bodyCell.bits.writeUint(process.env.ITEM_INDEX, 64) // ItemIndex
bodyCell.bits.writeCoins(toNano(0.02))

let itemContent = new Cell()
itemContent.bits.writeBuffer(Buffer.from(process.env.CONTENT))

let nftItemMessage = new Cell()
nftItemMessage.bits.writeAddress(ownerAddress)
nftItemMessage.refs.push(itemContent)
nftItemMessage.bits.writeAddress(authorityAddress) // Authority Address
nftItemMessage.bits.writeUint(0, 64) // revoked_at
bodyCell.refs.push(nftItemMessage)

const client = new TonClient({ endpoint: process.env.CLIENT_ENDPOINT, apiKey: process.env.CLIENT_API_KEY });

let secretKey = Buffer.from(process.env.MANAGER_SECRET_KEY, 'hex')
let publicKey = Buffer.from(process.env.MANAGER_PUBLIC_KEY, 'hex')

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
      to: contract,
      value: toNano(0.05),
      bounce: false,
      body: contractMessage
  })
 })

if (process.env.DRY_RUN != 'true') {
  await client.sendExternalMessage(wallet_contract, transfer)
}
