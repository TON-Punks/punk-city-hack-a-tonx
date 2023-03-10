# == Schema Information
#
# Table name: punks
#
#  id                     :bigint           not null, primary key
#  address                :string
#  animated_at            :datetime
#  animation_requested_at :datetime
#  base64_address         :string
#  experience             :bigint           default(0), not null
#  image_url              :string
#  number                 :string
#  owner                  :string
#  prestige_expirience    :integer          default(0), not null
#  prestige_level         :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_punks_on_address         (address)
#  index_punks_on_base64_address  (base64_address)
#  index_punks_on_owner           (owner)
#
class Punk < ApplicationRecord
  include AwsHelper

  has_many :punk_connections, dependent: :destroy
  has_many :dao_proposals
  has_one :connected_punk_connection, -> { connected }, class_name: 'PunkConnection'
  has_one :user, through: :connected_punk_connection

  scope :animated, -> { where.not(animated_at: nil) }
  scope :not_animated, -> { where(animated_at: nil) }

  # [DEPRECATED] These columns should be removed some time after stabilization
  self.ignored_columns = [:expirience, :total_experience, :level]

  def punk_url
    AwsConfig.punk_url(number)
  end

  def animated_gif_punk_url
    s3_object(AwsConfig.animated_gif_punk_path(number)).presigned_url(:get, expires_in: 1.week.to_i)
  end

  def animated_punk_url
    s3_object(AwsConfig.animated_punk_path(number)).presigned_url(:get, expires_in: 1.week.to_i)
  end
end
