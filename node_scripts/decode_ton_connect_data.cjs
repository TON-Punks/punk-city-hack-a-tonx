const TonProtocol = require('@tonconnect/protocol')
const { SessionCrypto, WalletMessage, Base64, hexToByteArray } = TonProtocol

const keyPair = { publicKey: process.env.PUBLIC_KEY, secretKey: process.env.SECRET_KEY }
const sessionCrypto = new SessionCrypto(keyPair)
const message = process.env.MESSAGE
const from = process.env.FROM
const decrypted = sessionCrypto.decrypt(Base64.decode(message).toUint8Array(), hexToByteArray(from))

console.log(decrypted)
process.exit()
