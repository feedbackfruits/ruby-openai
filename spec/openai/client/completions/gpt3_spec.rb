RSpec.describe OpenAI::Client do
  shared_examples_for "#completions: GPT-3 models" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "Once upon a time" }
      let(:max_tokens) { 5 }

      let(:text) { JSON.parse(response.body)["choices"][0]["text"] }
      let(:cassette) { "#{model} completions #{prompt}".downcase }

      context "with model: text-ada-001" do
        let(:model) { "text-ada-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: text-babbage-001" do
        let(:model) { "text-babbage-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: text-curie-001" do
        let(:model) { "text-curie-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: text-davinci-001" do
        let(:model) { "text-davinci-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end
    end
  end

  let(:response) do
    OpenAI::Client.new.completions(
      parameters: {
        model: model,
        prompt: prompt,
        max_tokens: max_tokens
      }
    )
  end

  it_behaves_like "#completions: GPT-3 models"

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
      OpenAI::Client.new.completions(
        deployment_id: model,
        parameters: {
          prompt: prompt,
          max_tokens: max_tokens
        }
      )
    end

    it_behaves_like "#completions: GPT-3 models"
  end
end
