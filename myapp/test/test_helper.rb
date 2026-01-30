ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # --- application specific settings ---
    include ActionDispatch::TestProcess

    def uploaded_image(filename: "sample.jpg", content_type: "image/jpeg")
      fixture_file_upload(Rails.root.join("test/fixtures/files/#{filename}"), content_type)
    end

    def create_photo!(user:, title:, image: uploaded_image, **attrs)
      photo = user.photos.new({ title: title }.merge(attrs))
      photo.image.attach(image)
      photo.save!
      photo
    end
  end
end
