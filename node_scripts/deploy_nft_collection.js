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

let compiledBoc = "b5ee9c72010213010001fe000114ff00f4a413f4bcf2c80b0102016202030202cd04050201200d0e03ebd10638048adf000e8698180b8d848adf07d201800e98fe99ff6a2687d20699fea6a6a184108349e9ca829405d47141baf8280e8410854658056b84008646582a802e78b127d010a65b509e58fe59f80e78b64c0207d80701b28b9e382f970c892e000f18112e001718119026001f1812f82c207f9784060708020120090a00603502d33f5313bbf2e1925313ba01fa00d43028103459f0068e1201a44343c85005cf1613cb3fccccccc9ed54925f05e200a6357003d4308e378040f4966fa5208e2906a4208100fabe93f2c18fde81019321a05325bbf2f402fa00d43022544b30f00623ba9302a402de04926c21e2b3e6303250444313c85005cf1613cb3fccccccc9ed54002801fa40304144c85005cf1613cb3fccccccc9ed540201200b0c003d45af0047021f005778018c8cb0558cf165004fa0213cb6b12ccccc971fb008002d007232cffe0a33c5b25c083232c044fd003d0032c03260001b3e401d3232c084b281f2fff274200201200f100025bc82df6a2687d20699fea6a6a182de86a182c40043b8b5d31ed44d0fa40d33fd4d4d43010245f04d0d431d430d071c8cb0701cf16ccc980201201112002fb5dafda89a1f481a67fa9a9a860d883a1a61fa61ff480610002db4f47da89a1f481a67fa9a9a86028be09e008e003e00b0"
const compiled = Buffer.from(compiledBoc, 'hex')

let codeCell = Cell.fromBoc(compiled)[0]

let ownerAddress = Address.parse(process.env.OWNER_ADDRESS)

let nftItemBoc = "b5ee9c720102130100033b000114ff00f4a413f4bcf2c80b0102016202030202ce04050201200f1004bd46c2220c700915be001d0d303fa4030f002f842b38e1c31f84301c705f2e195fa4001f864d401f866fa4030f86570f867f003e002d31f0271b0e30201d33f8210d0c3bfea5230bae302821004ded1485230bae3023082102fcb26a25220ba8060708090201200d0e00943031d31f82100524c7ae12ba8e39d33f308010f844708210c18e86d255036d804003c8cb1f12cb3f216eb39301cf179131e2c97105c8cb055004cf1658fa0213cb6accc901fb009130e200c26c12fa40d4d30030f847f841c8cbff5006cf16f844cf1612cc14cb3f5230cb0003c30096f8465003cc02de801078b17082100dd607e3403514804003c8cb1f12cb3f216eb39301cf179131e2c97105c8cb055004cf1658fa0213cb6accc901fb0000c632f8445003c705f2e191fa40d4d30030f847f841c8cbfff844cf1613cc12cb3f5210cb0001c30094f84601ccde801078b17082100524c7ae405503804003c8cb1f12cb3f216eb39301cf179131e2c97105c8cb055004cf1658fa0213cb6accc901fb0003fa8e4031f841c8cbfff843cf1680107082108b7717354015504403804003c8cb1f12cb3f216eb39301cf179131e2c97105c8cb055004cf1658fa0213cb6accc901fb00e082101f04537a5220bae30282106f89f5e35220ba8e165bf84501c705f2e191f847c000f2e193f823f867f003e08210d136d3b35220bae30230310a0b0c009231f84422c705f2e1918010708210d53276db102455026d830603c8cb1f12cb3f216eb39301cf179131e2c97105c8cb055004cf1658fa0213cb6accc901fb008b02f8648b02f865f003008e31f84422c705f2e191820afaf08070fb028010708210d53276db102455026d830603c8cb1f12cb3f216eb39301cf179131e2c97105c8cb055004cf1658fa0213cb6accc901fb00002082105fcc3d14ba93f2c19dde840ff2f000613b513434cfc07e187e90007e18dc3e188835d2708023859ffe18be90007e1935007e19be90007e1974cfcc3e19e44c38a000373e11fe11be107232cffe10f3c5be1133c5b33e1173c5b2cff27b55200201581112001dbc7e7f8017c217c20fc21fc227c234000db5631e005f08b0000db7b07e005f08f0"
let nftItemCode = Cell.fromBoc(Buffer.from(nftItemBoc, 'hex'))[0]

  let dataCell = new Cell()
  dataCell.bits.writeAddress(ownerAddress)
  dataCell.bits.writeUint(0, 64)

  let contentCell = new Cell()
  let collectionContent = encodeOffChainContent(process.env.CONTENT)
  let commonContent = new Cell()
  commonContent.bits.writeBuffer(Buffer.from(''))
  contentCell.refs.push(collectionContent)
  contentCell.refs.push(commonContent)
  dataCell.refs.push(contentCell)

  dataCell.refs.push(nftItemCode)

  let royaltyCell = new Cell()
  royaltyCell.bits.writeUint(0, 16 + 16)
  royaltyCell.bits.writeAddress(ownerAddress)
  dataCell.refs.push(royaltyCell)
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
      value: toNano(0.3),
      bounce: false,
      body: contractMessage
  })
 })

if (process.env.DRY_RUN != 'true') {
  await client.sendExternalMessage(wallet_contract, transfer)
}
