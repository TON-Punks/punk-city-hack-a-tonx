const TonConnect = require('@tonconnect/sdk').TonConnect

let storage = {
  setItem: function(key, value) {
    return Promise.resolve()
  },
  getItem: function(key, value) {
    return Promise.resolve()
  },
  removeItem: function(key, value) {
    return Promise.resolve()
  }
}

let connector = new TonConnect({ manifestUrl: 'https://punk-metaverse.fra1.digitaloceanspaces.com/service%2Fton_connect_manifest.json', storage: storage });
const url = connector.connect({ universalLink: 'https://app.tonkeeper.com/ton-connect', bridgeUrl: 'https://bridge.tonapi.io/bridge' })
const keyPair = connector.provider.session.sessionCrypto.stringifyKeypair()

console.log(`url: ${url}\npublicKey: ${keyPair.publicKey}\nsecretKey: ${keyPair.secretKey}`)
process.exit()
