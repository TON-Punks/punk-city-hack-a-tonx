RSpec.shared_examples "web app authenticated" do
  let(:user) { create(:user) }

  let(:request_init_data) { "request_init_data" }

  before do
    request.headers["Authorization"] = "Bearer #{request_init_data}"

    allow(Api::InitDataProcessor).to receive(:call).with(init_data: request_init_data).and_return(
      OpenStruct.new(success?: true, user: user)
    )
  end
end
