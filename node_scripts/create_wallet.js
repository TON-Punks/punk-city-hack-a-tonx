import TonWeb from 'tonweb';

const tonweb = new TonWeb();

const publicKey = TonWeb.utils.hexToBytes(process.env.PUBLIC_KEY)
const secretKey = TonWeb.utils.hexToBytes(process.env.SECRET_KEY);

// console.log()
const w = tonweb.wallet
w.defaultVersion = 'v3R2';
w.default = w.all[w.defaultVersion];

const wallet = w.create({publicKey, wc: 0})

const onError = function (e) {
  console.log(`error: ${e}`)
}

wallet.deploy(secretKey).send().then((res) => {
  console.log(`deployed`)
  console.log(res)
}).catch(onError)
