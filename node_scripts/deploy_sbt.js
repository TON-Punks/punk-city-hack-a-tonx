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


let compiledBoc = "b5ee9c720102190100043c000114ff00f4a413f4bcf2c80b0102016202030202ce040502012013140201200607020120111201f70c8871c02497c0f83434c0fe903e900c7e800c5c75c87e800c7e800c3c0080f4c7c0dc6c2394440917c134c7e084014931eb84aea38fb4cfcc20043e109c20843063a1b49540db601000f232c7d48832cfc85bace4c073c5e44c78b25c41b232c1540173c59400fe808532da84b332cff2407ec0244c38b800b4cfe00800113e910c1c2ebcb8536004fa82102fcb26a25240ba8e45306c223270c8cbff8b02cf1680107082108b771735405503804003c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb00e08210d0c3bfea5240bae302821004ded1485240bae30282101c04412a5240bae302343482101a0b9d515220ba090a0b0c00ca6c33fa40d4d30030f84570c8cbff5006cf16f842cf1612cc14cb3f5230cb0003c30096f8435003cc02de801078b17082100dd607e3403514804003c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb0000d26c33f8425003c705f2e19101fa40d4d30030f84570c8cbfff842cf1613cc12cb3f5210cb0001c30094f84301ccde801078b17082100524c7ae405503804003c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb000290334003f84114c705f2e191fa4021f001fa40d20031fa00820afaf08017a121945315a0a1de22d70b01c300209206a19136e220c2fff2e19221923630e30d03926c31e30df861f0030d0e02fe8e103132f84112c705f2e19ad430f863f003e03282101f04537a5210ba8e4c30f84221c705f2e1918010708210d53276db41046d830603c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb008b02f8628b02f864f003e082106f89f5e35210bae3028210d136d3b352100f100084c8f841cf165007cf1680108210511a446313712654485003c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb00007622f00180108210d53276db1445036d7103c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb00002e3031f84401c705f2e191f845c000f2e193f823f865f00300c0ba8e4a30f84221c705f2e191820afaf08070fb028010708210d53276db41046d830603c8cb1f5220cb3f216eb39301cf179131e2c97106c8cb055005cf165003fa0214cb6a12cccb3fc901fb00e06c2182105fcc3d14ba93f2c19dde840ff2f000373b51343e90007e18be90007e1875007e18fe90007e1934cfcc3e1960002f3e117e10f23e10b3c5be1073c5b33e1133c5b2cff27b552002015815160019bc7e7f8013fb845817c217c21c000db5631e005f08900201201718000db01d3c00be1060000db360fc00be1160"
const compiled = Buffer.from(compiledBoc, 'hex')

let codeCell = Cell.fromBoc(compiled)[0]

let editorAddress = Address.parse(process.env.EDITOR_ADDRESS)
let ownerAddress = Address.parse(process.env.OWNER_ADDRESS)

let dataCell = new Cell();
let contentCell = encodeOffChainContent(process.env.CONTENT)

dataCell.bits.writeAddress(ownerAddress)
dataCell.bits.writeAddress(editorAddress)
dataCell.refs.push(contentCell)
dataCell.bits.writeUint(0, 2)
dataCell.bits.writeUint(0, 64)

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
