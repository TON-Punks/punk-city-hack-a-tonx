# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_03_06_221536) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ab_testing_experiments", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.boolean "participates"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "type"], name: "index_ab_testing_experiments_on_user_id_and_type", unique: true
    t.index ["user_id"], name: "index_ab_testing_experiments_on_user_id"
  end

  create_table "battle_passes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "kind"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_battle_passes_on_user_id"
  end

  create_table "black_market_products", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "min_price", default: 0, null: false
    t.bigint "current_price", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_black_market_products_on_slug", unique: true
  end

  create_table "black_market_purchases", force: :cascade do |t|
    t.bigint "black_market_product_id", null: false
    t.bigint "user_id", null: false
    t.bigint "praxis_transaction_id"
    t.json "data", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0, null: false
    t.integer "payment_method", default: 0, null: false
    t.decimal "payment_amount", precision: 16, scale: 10, default: "0.0", null: false
    t.bigint "seller_user_id"
    t.decimal "seller_comission_amount", precision: 16, scale: 10, default: "0.0", null: false
    t.index ["black_market_product_id"], name: "index_black_market_purchases_on_black_market_product_id"
    t.index ["praxis_transaction_id"], name: "index_black_market_purchases_on_praxis_transaction_id"
    t.index ["seller_user_id"], name: "index_black_market_purchases_on_seller_user_id"
    t.index ["user_id"], name: "index_black_market_purchases_on_user_id"
  end

  create_table "crm_notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "crm_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "segment_id"
    t.index ["user_id"], name: "index_crm_notifications_on_user_id"
  end

  create_table "dao_proposal_votes", force: :cascade do |t|
    t.bigint "punk_id", null: false
    t.bigint "dao_proposal_id", null: false
    t.integer "state", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dao_proposal_id"], name: "index_dao_proposal_votes_on_dao_proposal_id"
    t.index ["punk_id", "dao_proposal_id"], name: "index_dao_proposal_votes_on_punk_id_and_dao_proposal_id", unique: true
  end

  create_table "dao_proposals", force: :cascade do |t|
    t.text "name"
    t.text "description"
    t.bigint "punk_id", null: false
    t.datetime "expires_at"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "has_cover", default: false, null: false
    t.index ["punk_id"], name: "index_dao_proposals_on_punk_id"
  end

  create_table "free_tournaments", force: :cascade do |t|
    t.integer "state", null: false
    t.datetime "start_at", null: false
    t.datetime "finish_at", null: false
    t.bigint "prize_amount", null: false
    t.integer "prize_currency", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "dynamic_prize_enabled", default: false, null: false
  end

  create_table "game_rounds", force: :cascade do |t|
    t.bigint "rock_paper_scissors_game_id", null: false
    t.string "winner"
    t.integer "opponent"
    t.integer "creator"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "winner_damage", default: 0, null: false
    t.integer "winner_modifier"
    t.integer "loser_modifier"
    t.integer "loser_damage"
    t.integer "creator_damage", default: 0, null: false
    t.integer "opponent_damage", default: 0, null: false
    t.index ["rock_paper_scissors_game_id"], name: "index_game_rounds_on_rock_paper_scissors_game_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "data", default: {}, null: false
    t.index ["name"], name: "index_items_on_name", unique: true
  end

  create_table "items_users", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "data", default: {}, null: false
    t.index ["item_id"], name: "index_items_users_on_item_id"
    t.index ["user_id"], name: "index_items_users_on_user_id"
  end

  create_table "lootboxes", force: :cascade do |t|
    t.bigint "black_market_purchase_id"
    t.text "address"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "series", null: false
    t.jsonb "result"
    t.boolean "prepaid", default: false, null: false
    t.index ["black_market_purchase_id"], name: "index_lootboxes_on_black_market_purchase_id"
  end

  create_table "missions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "type", null: false
    t.jsonb "data", default: {}, null: false
    t.integer "state", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_missions_on_user_id"
  end

  create_table "platformer_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "score"
    t.datetime "finished_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_platformer_games_on_user_id"
  end

  create_table "platformer_statistics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "top_score", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_platformer_statistics_on_user_id"
  end

  create_table "praxis_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "operation_type", null: false
    t.bigint "quantity", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_praxis_transactions_on_user_id"
  end

  create_table "punk_connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "punk_id", null: false
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "connected_at"
    t.index ["punk_id"], name: "index_punk_connections_on_punk_id"
    t.index ["user_id"], name: "index_punk_connections_on_user_id"
  end

  create_table "punks", force: :cascade do |t|
    t.string "address"
    t.string "base64_address"
    t.string "owner"
    t.string "number"
    t.string "image_url"
    t.bigint "expirience", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "total_experience", default: 0, null: false
    t.datetime "animated_at"
    t.integer "prestige_level", default: 0, null: false
    t.integer "prestige_expirience", default: 0, null: false
    t.datetime "animation_requested_at"
    t.bigint "experience", default: 0, null: false
    t.index ["address"], name: "index_punks_on_address"
    t.index ["base64_address"], name: "index_punks_on_base64_address"
    t.index ["owner"], name: "index_punks_on_owner"
  end

  create_table "referral_rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "referral_id", null: false
    t.bigint "rock_paper_scissors_game_id", null: false
    t.integer "experience", default: 0, null: false
    t.integer "praxis", default: 0, null: false
    t.decimal "ton", precision: 16, scale: 10, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["referral_id", "rock_paper_scissors_game_id"], name: "index_referral_rewards_on_referrals_and_game", unique: true
    t.index ["referral_id"], name: "index_referral_rewards_on_referral_id"
    t.index ["rock_paper_scissors_game_id"], name: "index_referral_rewards_on_rock_paper_scissors_game_id"
    t.index ["user_id"], name: "index_referral_rewards_on_user_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "referred_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["referred_id"], name: "index_referrals_on_referred_id", unique: true
    t.index ["user_id"], name: "index_referrals_on_user_id"
  end

  create_table "rock_paper_scissors_games", force: :cascade do |t|
    t.jsonb "rounds", default: [], null: false
    t.bigint "creator_id", null: false
    t.bigint "opponent_id"
    t.boolean "bot", default: false, null: false
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "bet", default: 0, null: false
    t.integer "visibility", default: 0, null: false
    t.string "address"
    t.integer "blockchain_state"
    t.integer "creator_experience"
    t.integer "opponent_experience"
    t.string "bot_strategy"
    t.text "boss"
    t.integer "bet_currency"
    t.json "current_weapons", default: {}, null: false
    t.index ["creator_id"], name: "index_rock_paper_scissors_games_on_creator_id"
    t.index ["opponent_id"], name: "index_rock_paper_scissors_games_on_opponent_id"
    t.index ["state"], name: "index_rock_paper_scissors_games_on_state"
  end

  create_table "rock_paper_scissors_notifications", force: :cascade do |t|
    t.string "chat_id"
    t.bigint "rock_paper_scissors_game_id", null: false
    t.string "message_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "inline_message_id"
    t.string "locale", default: "en", null: false
    t.boolean "temporary", default: true, null: false
    t.index ["rock_paper_scissors_game_id"], name: "index_rock_paper_scissors_notifications_on_game_id"
  end

  create_table "rock_paper_scissors_statistics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "winrate"
    t.bigint "ton_won"
    t.bigint "ton_lost"
    t.bigint "games_won"
    t.bigint "games_lost"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "praxis_won"
    t.bigint "praxis_lost"
    t.index ["user_id"], name: "index_rock_paper_scissors_statistics_on_user_id"
  end

  create_table "segments", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "type"], name: "index_segments_on_name_and_type", unique: true
  end

  create_table "segments_users", force: :cascade do |t|
    t.bigint "segment_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["segment_id", "user_id"], name: "index_segments_users_on_segment_id_and_user_id", unique: true
    t.index ["segment_id"], name: "index_segments_users_on_segment_id"
    t.index ["user_id"], name: "index_segments_users_on_user_id"
  end

  create_table "tournament_tickets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tournament_id"
    t.bigint "platformer_game_id"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "rock_paper_scissors_game_id"
    t.index ["platformer_game_id"], name: "index_tournament_tickets_on_platformer_game_id"
    t.index ["rock_paper_scissors_game_id"], name: "index_tournament_tickets_on_rock_paper_scissors_game_id"
    t.index ["tournament_id"], name: "index_tournament_tickets_on_tournament_id"
    t.index ["user_id"], name: "index_tournament_tickets_on_user_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.datetime "finishes_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "kind"
    t.bigint "balance", default: 0, null: false
    t.string "address"
    t.datetime "expires_at"
  end

  create_table "user_free_tournament_statistics", force: :cascade do |t|
    t.bigint "free_tournament_id", null: false
    t.bigint "user_id", null: false
    t.integer "games_won", default: 0, null: false
    t.integer "games_lost", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "score", default: 0, null: false
    t.integer "position"
    t.integer "reward"
    t.index ["free_tournament_id", "user_id"], name: "index_on_free_tournament_statistics", unique: true
    t.index ["free_tournament_id"], name: "index_user_free_tournament_statistics_on_free_tournament_id"
    t.index ["user_id"], name: "index_user_free_tournament_statistics_on_user_id"
  end

  create_table "user_halloween_statistics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "total_damage", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_halloween_statistics_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "closed_at"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "user_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "user_session_id"
    t.bigint "total", null: false
    t.bigint "commission", null: false
    t.string "transaction_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_transactions_on_user_id"
    t.index ["user_session_id"], name: "index_user_transactions_on_user_session_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "chat_id", null: false
    t.string "username"
    t.string "locale"
    t.integer "level", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "expirience", default: 0, null: false
    t.string "next_step"
    t.boolean "onboarded", default: false, null: false
    t.datetime "last_match_at"
    t.string "first_name"
    t.string "last_name"
    t.string "provided_wallet"
    t.bigint "total_experience", default: 0, null: false
    t.integer "prestige_level", default: 0, null: false
    t.integer "prestige_expirience", default: 0, null: false
    t.bigint "chat_rep", default: 0, null: false
    t.bigint "experience", default: 0, null: false
    t.datetime "unsubscribed_at"
    t.datetime "notifications_disabled_at"
    t.datetime "viewed_tutorial_at"
    t.string "utm_source"
    t.integer "free_lootboxes_rewarded_level", default: 0, null: false
    t.index ["chat_id"], name: "index_users_on_chat_id", unique: true
  end

  create_table "wallet_credentials", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.text "public_key"
    t.text "secret_key"
    t.text "mnemonic"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["wallet_id"], name: "index_wallet_credentials_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.string "address"
    t.bigint "balance"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.integer "state", default: 0, null: false
    t.string "base64_address_bounce"
    t.string "base64_address"
    t.bigint "virtual_balance", default: 0, null: false
    t.index ["base64_address_bounce"], name: "index_wallets_on_base64_address_bounce"
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  create_table "withdraw_requests", force: :cascade do |t|
    t.string "address"
    t.bigint "amount"
    t.bigint "wallet_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["wallet_id"], name: "index_withdraw_requests_on_wallet_id"
  end

  create_table "zeya_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "score"
    t.datetime "finished_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_zeya_games_on_user_id"
  end

  create_table "zeya_statistics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "top_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_zeya_statistics_on_user_id"
  end

  add_foreign_key "ab_testing_experiments", "users"
  add_foreign_key "battle_passes", "users"
  add_foreign_key "black_market_purchases", "black_market_products"
  add_foreign_key "black_market_purchases", "praxis_transactions"
  add_foreign_key "black_market_purchases", "users"
  add_foreign_key "crm_notifications", "users"
  add_foreign_key "dao_proposal_votes", "dao_proposals"
  add_foreign_key "dao_proposal_votes", "punks"
  add_foreign_key "dao_proposals", "punks"
  add_foreign_key "game_rounds", "rock_paper_scissors_games"
  add_foreign_key "items_users", "items"
  add_foreign_key "items_users", "users"
  add_foreign_key "missions", "users"
  add_foreign_key "platformer_games", "users"
  add_foreign_key "platformer_statistics", "users"
  add_foreign_key "praxis_transactions", "users"
  add_foreign_key "punk_connections", "punks"
  add_foreign_key "punk_connections", "users"
  add_foreign_key "referral_rewards", "rock_paper_scissors_games"
  add_foreign_key "referral_rewards", "users"
  add_foreign_key "referral_rewards", "users", column: "referral_id"
  add_foreign_key "referrals", "users"
  add_foreign_key "referrals", "users", column: "referred_id"
  add_foreign_key "rock_paper_scissors_games", "users", column: "creator_id"
  add_foreign_key "rock_paper_scissors_games", "users", column: "opponent_id"
  add_foreign_key "rock_paper_scissors_notifications", "rock_paper_scissors_games"
  add_foreign_key "rock_paper_scissors_statistics", "users"
  add_foreign_key "segments_users", "segments"
  add_foreign_key "segments_users", "users"
  add_foreign_key "tournament_tickets", "platformer_games"
  add_foreign_key "tournament_tickets", "rock_paper_scissors_games"
  add_foreign_key "tournament_tickets", "tournaments"
  add_foreign_key "tournament_tickets", "users"
  add_foreign_key "user_free_tournament_statistics", "free_tournaments"
  add_foreign_key "user_free_tournament_statistics", "users"
  add_foreign_key "user_halloween_statistics", "users"
  add_foreign_key "user_sessions", "users"
  add_foreign_key "user_transactions", "user_sessions"
  add_foreign_key "user_transactions", "users"
  add_foreign_key "wallet_credentials", "wallets"
  add_foreign_key "wallets", "users"
  add_foreign_key "withdraw_requests", "wallets"
  add_foreign_key "zeya_games", "users"
  add_foreign_key "zeya_statistics", "users"
end
