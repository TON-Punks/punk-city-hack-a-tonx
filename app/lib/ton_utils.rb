module TonUtils
  TEST_TAG = 0x80
  BOUNCABLE_TAG = 0x11
  NONBOUNCABLE_TAG = 0x51
  MASTER_WORKCHAIN = 0xff

  module_function

  def hex_address(base64)
    bytes = Base64.urlsafe_decode64(base64).bytes
    raise "Unknown address type: byte length is not equal to 36" if bytes.size != 36

    addr = bytes[0, 34]
    _crc = bytes[34, 36]

    _tag = addr[0]

    hex = addr[2..-1].pack("c*").unpack("H*").first
    workchain = addr[1] == MASTER_WORKCHAIN ? -1 : addr[1]

    "#{workchain}:#{hex}"
  end
end
