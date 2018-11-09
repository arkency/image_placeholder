require 'spec_helper'
require 'rack/test'

module ImagePlaceholder
  RSpec.describe Middleware do
    include Rack::Test::Methods

    specify 'pass through found images' do
      get 'ruby.jpg'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('image/jpeg')
      expect(last_response.content_length).to eq(ruby_jpg_size)
    end

    specify 'replace not found image with placeholder' do
      get 'crystal.jpg'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('image/png')
      expect(last_response.content_length).to eq(placeholder_size(100))
    end

    specify 'pass through not found non-images' do
      get 'ruby.html'

      expect(last_response.status).to eq(404)
      expect(last_response.content_type).to eq('text/plain')
      expect(last_response.content_length).to eq("File not found: /ruby.html\n".size)
    end

    specify 'pass through found non-images' do
      get 'ruby.txt'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('text/plain')
      expect(last_response.content_length).to eq("Ruby".size)
    end

    specify 'pass through not found images with unrecognized extensions' do
      get 'ruby.png'

      expect(last_response.status).to eq(404)
      expect(last_response.content_type).to eq('text/plain')
      expect(last_response.content_length).to eq("File not found: /ruby.png\n".size)
    end

    specify 'match size for missing s_dummy.jpg' do
      get 'uploads/product/cover/10001/s_9781467775687.jpg'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('image/png')
      expect(last_response.content_length).to eq(placeholder_size(200))
    end

    specify 'match size for missing xl_dummy.jpg' do
      get 'uploads/product/cover/10001/xl_9781467775687.jpg'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('image/png')
      expect(last_response.content_length).to eq(placeholder_size(400))
    end

    def ruby_jpg_size
      File.size(File.join(static_path, 'ruby.jpg'))
    end

    def placeholder_size(size)
      net_response = Net::HTTP.get_response(URI("https://via.placeholder.com/#{size}"))
      net_response['Content-Length'].to_i
    end

    def static_path
      File.expand_path(File.join(__dir__, 'support'))
    end

    def app
      Rack::Lint.new(
        Middleware.new(
          Rack::File.new(static_path),
          image_extensions: %w(jpg),
          size_pattern: {
            %r{/uploads/.*/s_[0-9]+\.[a-z]{3}$} => 200,
            %r{/uploads/.*/xl_[0-9]+\.[a-z]{3}$} => 400,
            %r{.*} => 100,
          }
        )
      )
    end
  end
end
