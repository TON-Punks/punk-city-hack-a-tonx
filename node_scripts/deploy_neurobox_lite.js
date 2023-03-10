import fs from 'fs'
import { compileFunc, compileFift } from 'tonc'
import  Ton from 'ton'

const { Cell, Address, TonClient, CellMessage, contractAddress, serializeDict, CommonMessageInfo, StateInit, ExternalMessage, HttpApi, InMemoryCache, toNano, WalletContract, InternalMessage, WalletV3R2Source } = Ton

const client = new TonClient({
  endpoint: "https://toncenter.com/api/v2/jsonRPC",
  apiKey: "9cecd4b376aa13928fb399b462ec1a80e7e9453fa56eabd277c6473568fc88db",
});

const source = fs.readFileSync("smart_contracts/lootbox-lite.func").toString('utf-8');
let fift = await compileFunc(source)
let compiled = await compileFift(fift)
console.log(compiled.toString('hex'))

let codeCell = Cell.fromBoc(compiled)[0]

let secretKey = Buffer.from(process.env.MANAGER_SECRET_KEY, "hex");
let publicKey = Buffer.from(process.env.MANAGER_PUBLIC_KEY, "hex");

const contractSource = {
  initialCode: codeCell,
  workchain: 0,
  type: ''
}

const address = contractAddress(contractSource)
console.log(`address: ${address.toString()}`);
console.log(`base64_address: ${address.toFriendly()}`);

let msgCell = new Cell()

const wallet_contract = WalletContract.create(
  client,
  WalletV3R2Source.create({ publicKey, workchain: 0 })
);
const contractMessage = new CommonMessageInfo({
  stateInit: new StateInit({
    code: contractSource.initialCode,
  }),
  body: new CellMessage(msgCell),
});

const seqNo = await wallet_contract.getSeqNo();
const transfer = wallet_contract.createTransfer({
  secretKey: secretKey,
  seqno: seqNo,
  sendMode: 0,
  order: new InternalMessage({
    to: address,
    value: toNano(0.01),
    bounce: true,
    body: contractMessage,
  }),
});

await client.sendExternalMessage(wallet_contract, transfer);
