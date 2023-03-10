import TonWeb from 'tonweb';

const tonweb = new TonWeb();
import tonMnemonic from "tonweb-mnemonic";


function toHexString(byteArray) {
  return Array.prototype.map.call(byteArray, function(byte) {
      return ('0' + (byte & 0xFF).toString(16)).slice(-2);
  }).join('');
}


const onError = function (e) {
  console.log(`error: ${e}`)
}

tonMnemonic.generateMnemonic().then((mnemonic) => {
  console.log(`mnemonic: ` + mnemonic.join(" "))
   tonMnemonic.mnemonicToKeyPair(mnemonic).then((keyPair) => {
       console.log(`public_key: ${toHexString(keyPair.publicKey)}`)
       console.log(`secret_key: ${toHexString(keyPair.secretKey)}`)

       const w = tonweb.wallet
        w.defaultVersion = 'v3R2';
        w.default = w.all[w.defaultVersion];
        const wallet = w.create({publicKey: keyPair.publicKey})

        wallet.getAddress().then((address) => {
          console.log(`address: ${address}`)
          address.isUserFriendly = true
          address.isUrlSafe = true
          console.log(`base64_address: ${address}`)
          address.isBounceable = true
          console.log(`base64_address_bounce: ${address}`)
        }).catch(onError)
   }).catch(onError)
}).catch(onError)
