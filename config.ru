require 'image_placeholder'

use ImagePlaceholder::Middleware, size_pattern: { /.*/ => 320 }
run Rack::File.new(File.expand_path(File.join(__dir__, 'spec/support')))
