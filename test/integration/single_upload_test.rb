require 'test_helper'

class SingleUploadTest < CapybaraTest

  test "can upload a single file" do
    visit new_user_path
    assert has_selector?(".new_user .file ul")
    assert has_no_selector?(".new_user .file ul li")
  end

end