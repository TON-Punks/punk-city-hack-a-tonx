class Lootboxes::CheckResult
  include Interactor

  SCRIPT_PATH = Rails.root.join("node_scripts/parse_lootbox_data.js")

  WEAPON_RESULTS = [0, 1, 3]
  WEAPON_RESULTS_TO_RARITY = {
    0 => :regular,
    1 => :rare,
    3 => :mythical,
  }

  LITEBOX_RESULT_MAPPING = {
    2 => :experience,
    4 => :praxis
  }

  def call
    transactions = transactions_for("lootboxes") + transactions_for("lootboxes_lite")

    transactions.each do |transaction|
      out_message = transaction['out_msgs'].first
      next if transaction['out_msgs'].first['destination'] != ContractsConfig.manager_base64_address

      msg_data = out_message['msg_data']['body']
      next if msg_data.blank?
      parsed_data = `MESSAGE_DATA=#{msg_data} node #{SCRIPT_PATH}`
      lootbox_id, _chance, rarity, weapon_position = parsed_data.split("\n").map(&:to_i)
      lootbox = Lootbox.find_by(id: lootbox_id)
      next if lootbox.blank? || lootbox.user.blank?
      next if lootbox.result.present?

      result = mapped_result(lootbox, rarity, weapon_position)
      lootbox.update(result: result, address: transaction['transaction_id']['hash'])
    end
  end

  private

  def mapped_result(lootbox, rarity, weapon_position)
    if lootbox.lite_series?
      mapped_litebox_result(lootbox, rarity, weapon_position)
    elsif lootbox.initial_series?
      mapped_weapon(lootbox, rarity, weapon_position)
    end
  end

  def mapped_litebox_result(lootbox, rarity, weapon_position)
    return mapped_weapon(lootbox, rarity, weapon_position) if WEAPON_RESULTS_TO_RARITY.keys.include?(rarity)

    series_content(lootbox).detect { |weapon| weapon[:type] == LITEBOX_RESULT_MAPPING[rarity] }
  end

  def mapped_weapon(lootbox, rarity, weapon_position)
    series_content(lootbox).select { |weapon| weapon[:data][:rarity] == WEAPON_RESULTS_TO_RARITY[rarity] }
        .detect { |weapon| weapon[:data][:position] == weapon_position}
  end

  def series_content(lootbox)
    Lootboxes::SERIES_TO_CONTENT[lootbox.series.to_sym]
  end

  def transactions_for(contract_name)
    toncenter_client.account_transactions(address: ContractsConfig.contracts_address[contract_name])
  end

  def toncenter_client
    @toncenter_client ||= ToncenterClient.new
  end
end
