RSpec.describe OpenAI::Client do
  describe "#embeddings", :vcr do
    let(:input) { "The food was delicious and the waiter..." }
    let(:cassette) { "#{model} embeddings #{input}".downcase }
    let(:response) do
      OpenAI::Client.new.embeddings(
        parameters: {
          model: model,
          input: input
        }
      )
    end

    shared_examples_for "with model: babbage-similarity" do
      let(:model) { "babbage-similarity" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["data"][0]["object"]).to eq("embedding")
        end
      end
    end

    it_behaves_like "with model: babbage-similarity"

    context "with Azure" do
      before do
        OpenAI.configure do |config|
          config.api_type = :azure
          config.api_version = "2022-12-01"
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
        OpenAI::Client.new.embeddings(
          deployment_id: model,
          parameters: {
            input: input
          }
        )
      end

      it_behaves_like "with model: babbage-similarity"
    end
  end
end
