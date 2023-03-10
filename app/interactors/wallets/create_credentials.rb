class Wallets::CreateCredentials
  include Interactor

  GENERATE_CREDENTIALS_PATH = Rails.root.join("node_scripts/generate_credentials.js")

  def call
    node_output = `node #{GENERATE_CREDENTIALS_PATH}`

    error = node_output.match(/error: (.*)/)
    raise RuntimeError, node_output if error

    context.mnemonic = node_output.match(/mnemonic: (.*)/)[1]
    context.public_key = node_output.match(/public_key: (.*)/)[1]
    context.secret_key = node_output.match(/secret_key: (.*)/)[1]
    context.address = node_output.match(/address: (.*)/)[1]
    context.base64_address = node_output.match(/base64_address: (.*)/)[1]
    context.base64_address_bounce = node_output.match(/base64_address_bounce: (.*)/)[1]
  end
end
