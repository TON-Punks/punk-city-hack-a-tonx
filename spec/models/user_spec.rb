require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create :user, :with_weapons }

  describe 'callbacks' do
    before { Items::Weapons::DEFAULT.each { Item.build_from_data(:weapon, _1).save } }

    let(:user) { build :user }

    specify do
      expect(Users::UpdateProfileWorker).to receive(:perform_async)
      user.save

      expect(user.equipped_weapons.count).to eq(5)
    end
  end

  describe 'bot?' do
    subject { create :user, :bot }

    its(:bot?) { is_expected.to eq(true) }
  end

  specify 'profile_url' do
    base_url = "https://punk-metaverse.fra1.digitaloceanspaces.com/profiles"
    timestamp = user.rock_paper_scissors_statistic.updated_at.to_i

    expect(user.profile_url).to eq("#{base_url}/#{user.id}.png?a=#{timestamp}")
  end

  specify 'profile_url' do
    base_url = "https://punk-metaverse.fra1.digitaloceanspaces.com/weapons_image"

    timestamp = user.items_users.maximum(:updated_at).to_i
    expect(user.weapons_image_url).to eq("#{base_url}/#{user.id}.png?a=#{timestamp}")
  end

  describe 'sorting' do
    let!(:user2) { create :user, prestige_level: 3, prestige_expirience: 310 }
    let!(:user3) { create :user, prestige_level: 2, prestige_expirience: 200 }
    let!(:user4) { create :user, prestige_level: 3, prestige_expirience: 300 }

    specify 'by_level' do
      expect(User.by_level.to_a).to eq([user2, user4, user3])
    end

  end

  describe 'created_rock_paper_scissors_games' do
    let!(:created_game) { create :rock_paper_scissors_game, creator: user }
    let!(:participated_game) { create :rock_paper_scissors_game, opponent: user }

    specify do
      expect(user.created_rock_paper_scissors_games).to match_array([created_game])
    end
  end

  describe 'created_rock_paper_scissors_games' do
    let(:user) { create :user }
    let!(:created_game) { create :rock_paper_scissors_game, creator: user }
    let!(:participated_game) { create :rock_paper_scissors_game, opponent: user }

    specify do
      expect(user.participated_rock_paper_scissors_games).to match_array([participated_game])
    end
  end

  describe 'created_rock_paper_scissors_games' do
    let(:user) { create :user }
    let!(:created_game) { create :rock_paper_scissors_game, creator: user, state: :opponent_won }
    let!(:participated_game) { create :rock_paper_scissors_game, opponent: user, state: :creator_won }

    before do
      create :rock_paper_scissors_game, creator: user, state: :archived
      create :rock_paper_scissors_game, creator: user, state: :created
    end

    specify do
      expect(user.rock_paper_scissors_games_total).to eq(2)
    end
  end

  describe 'punk_connetions' do
    let!(:user) { create :user }
    let!(:punk) { create :punk }
    let!(:punk_connections) { create_list :punk_connection, 2, user: user, punk: punk }

    specify do
      expect(user.punk).to be_blank
      expect(user.punk_connections.size).to eq(2)

      punk_connections.first.connected!
      expect(user.reload.punk).to eq(punk)


      user.connected_punk_connection.disconnected!
      expect(user.reload.punk).to be_blank
    end
  end

  describe '#remove_experience!' do
    let(:user) { create :user, prestige_level: 6, experience: 5000 }

    specify do
      user.remove_experience!(3000)
      expect(user.prestige_level).to eq(6)
      expect(user.experience).to eq(2000)
    end
  end

  describe 'referrals' do
    let(:user) { create :user }
    let(:referred) { create :user }
    let!(:referral) { create :referral, user: user, referred: referred }

    before {  create :referral, user: user }

    describe '#referred_users' do
      specify do
        expect(user.referrals.count).to eq(2)
        expect(user.referred_users.count).to eq(2)
        expect(user.referred_users.count).to eq(2)
        expect(user.referred_users).to include(referred)
      end

      it { expect(referred.referred_by).to eq(user) }
    end
  end

  describe 'add_experience!' do
    let(:user) { create(:user, prestige_expirience: 0, prestige_level: 0) }

    it do
      expect { user.add_experience!(300) }.to change { user.experience }.from(0).to(300)
      expect(user.experience).to eq(300)
      expect(user.prestige_expirience).to eq(100)
      expect(user.prestige_level).to eq(1)
    end

    context 'when punk is present' do
      let(:user) { create(:user, prestige_level: 1, prestige_expirience: 100) }
      let(:punk) { create(:punk, prestige_level: 2, prestige_expirience: 200) }

      before { create(:punk_connection, user: user, state: :connected, punk: punk) }

      specify do
        expect { user.add_experience!(100) }.to_not change { user.reload.experience }
        expect(user.prestige_expirience).to eq(100)
        expect(user.prestige_level).to eq(1)

        punk.reload
        expect(punk.prestige_expirience).to eq(300)
        expect(punk.prestige_level).to eq(2)
      end
    end

    context 'with previous experience' do
      let(:user) { create(:user, prestige_expirience: 500, prestige_level: 2, experience: 300) }

      specify do
        user.add_experience!(200)

        user.reload
        expect(user.experience).to eq(500)
        expect(user.prestige_expirience).to eq(100)
        expect(user.prestige_level).to eq(3)
      end

      context 'with referrer' do
        let(:referrer) { create(:user, prestige_expirience: 199, prestige_level: 0, experience: 199) }

        before { create(:referral, referred: user, user: referrer) }

        specify do
          user.add_experience!(100)

          user.reload
          expect(user.experience).to eq(400)
          expect(user.prestige_expirience).to eq(0)
          expect(user.prestige_level).to eq(3)

          referrer.reload
          expect(referrer.experience).to eq(201)
          expect(referrer.prestige_expirience).to eq(1)
          expect(referrer.prestige_level).to eq(1)
        end
      end
    end
  end

  describe 'game locking mechanics' do
    specify do
      expect(user.can_start_new_game?).to eq(true)
      user.lock_game_creation!
      expect(user.can_start_new_game?).to eq(false)
      user.unlock_game_creation!
      expect(user.can_start_new_game?).to eq(true)
    end
  end

  describe '#equipped_weapons' do
    let(:user) { create :user, :with_default_weapons }

    specify do
      expect { user.items_users.first.unequip! }.to change { user.equipped_weapons.count }.from(5).to(4)
    end
  end

  describe 'health' do
    let(:user) { create :user, :with_weapons, weapons_rarity: :regular }

    it { expect(user.health).to eq(50) }
  end
end
