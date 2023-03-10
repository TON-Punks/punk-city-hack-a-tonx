module AwsHelper
  BUCKET_NAME = "punk-metaverse".freeze

  private

  def upload_image(folder:, name:, body:)
    aws_client.put_object({
      bucket: BUCKET_NAME,
      key: "#{folder}/#{name}",
      body: body,
      acl: "public-read"
    })
  end

  def s3_object(key)
    s3_resource.bucket(BUCKET_NAME).object(key)
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new(client: aws_client)
  end

  def aws_client
    @aws_client ||= Aws::S3::Client.new(
      access_key_id: AwsConfig.access_key_id,
      secret_access_key: AwsConfig.secret_access_key,
      endpoint: AwsConfig.endpoint,
      region: AwsConfig.region
    )
  end
end
