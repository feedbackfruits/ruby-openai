RSpec.describe OpenAI::Client do
  describe "#chat", :vcr do
    let(:messages) { [{ role: "user", content: "Hello!" }] }
    let(:content) { JSON.parse(response.body).dig("choices", 0, "message", "content") }
    let(:cassette) { "#{model} chat".downcase }
    let(:response) do
      OpenAI::Client.new.chat(
        parameters: {
          model: model,
          messages: messages
        }
      )
    end

    context "with model: gpt-3.5-turbo-0301" do
      let(:model) { "gpt-3.5-turbo-0301" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(content.split.empty?).to eq(false)
        end
      end
    end

    shared_examples_for "with model: gpt-3.5-turbo" do
      let(:model) { "gpt-3.5-turbo" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(content.split.empty?).to eq(false)
        end
      end
    end

    it_behaves_like "with model: gpt-3.5-turbo"

    context "with Azure" do
      before do
        OpenAI.configure do |config|
          config.api_type = :azure
          config.api_version = "2023-03-15-preview"
          config.uri_base = ENV.fetch("AZURE_URI_BASE")
          config.access_token = ENV.fetch("AZURE_ACCESS_TOKEN")
        end
      end

      after do
        OpenAI.configure do |config|
          config.api_type = nil
          config.api_version = OpenAI::Configuration::DEFAULT_API_VERSION
          config.uri_base = OpenAI::Configuration::DEFAULT_URI_BASE
          config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
        end
      end

      let(:response) do
        OpenAI::Client.new.chat(
          deployment_id: "gpt-35-turbo",
          parameters: {
            messages: messages
          }
        )
      end

      it_behaves_like "with model: gpt-3.5-turbo"
    end
  end
end
