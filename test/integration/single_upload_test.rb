require 'test_helper'

class SingleUploadTest < CapybaraTest

  teardown do
    User.destroy_all
    DbFile.destroy_all
  end

  test "can upload a single file" do
    user_count = User.count
    file_count = DbFile.count

    visit new_user_path
    assert has_selector?(".new_user .file .inputs")
    assert has_no_selector?(".new_user .file .inputs input[type=hidden]")

    attach_file "user_avatar_file", File.expand_path("../../fixtures/avatar.jpeg", __FILE__)
    assert has_selector?(".new_user .file .inputs input[type=checkbox]")

    click_on "Create User"

    # should have validation error on name
    assert has_selector?(".new_user .error li")
    assert has_selector?(".new_user .file .inputs input[type=checkbox]"), "upload file should still be present"

    fill_in "Name", with: "John Smith"
    click_on "Create User"

    assert has_selector?("h1", text: "User: John Smith")

    assert_equal(user_count + 1, User.count, "should have created a user")
    assert_equal(file_count + 1, DbFile.count, "should have created a db file")

    file = DbFile.last
    assert_equal("avatar.jpeg", file.name)
  end

  test "can change file on create" do
    user_count = User.count
    file_count = DbFile.count

    visit new_user_path
    assert has_selector?(".new_user .file .inputs")
    assert has_no_selector?(".new_user .file .inputs input[type=hidden]")

    attach_file "user_avatar_file", File.expand_path("../../fixtures/avatar.jpeg", __FILE__)
    assert has_selector?(".new_user .file .inputs input[type=checkbox]", count: 1)
    fill_in "Name", with: "John Smith"

    attach_file "user_avatar_file", File.expand_path("../../fixtures/test_upload.txt", __FILE__)
    assert has_selector?(".new_user .file .inputs input[type=checkbox]", count: 1)
    click_on "Create User"

    assert has_selector?("h1", text: "User: John Smith")

    assert_equal(user_count + 1, User.count, "should have created a user")
    assert_equal(file_count + 1, DbFile.count, "should have created a db file")

    file = DbFile.last
    assert_equal("test_upload.txt", file.name)
  end

  test "can change file on edit" do
    user = User.create({
      name: "Bob",
      avatar: DbFile.new({
        name: "pic.jpg",
        size: 112,
        content_type: "image/jpeg",
        data: "blah"
      })
    })
    assert user.persisted?, "sanity check"

    user_count = User.count
    file_count = DbFile.count

    visit edit_user_path(user)
    assert has_selector?("h1", text: "Edit Bob")
    assert has_selector?(".edit_user .file .inputs input[type=checkbox]", count: 1)

    attach_file "user_avatar_file", File.expand_path("../../fixtures/avatar.jpeg", __FILE__)
    assert has_selector?(".edit_user .file .inputs", text: "avatar.jpeg", count: 1)
    fill_in "Name", with: "Bob2"

    click_on "Update User"
    assert has_selector?("h1", text: "User: Bob2")

    assert_equal(user_count, User.count)
    assert_equal(file_count, DbFile.count, "should not create a new record")

    user.reload
    file = user.avatar
    assert_equal("avatar.jpeg", file.name)
  end

  test "can remove file on edit" do
    user = User.create({
      name: "Bob",
      avatar: DbFile.new({
        name: "pic.jpg",
        size: 112,
        content_type: "image/jpeg",
        data: "blah"
      })
    })
    assert user.persisted?, "sanity check"

    user_count = User.count
    file_count = DbFile.count

    visit edit_user_path(user)
    assert has_selector?("h1", text: "Edit Bob")
    assert has_selector?(".edit_user .file .inputs input[type=checkbox]", count: 1)

    uncheck "pic.jpg"
    click_on "Update User"

    assert has_selector?("h1", text: "User: Bob")
    assert_equal(user_count, User.count)
    assert_equal(file_count - 1, DbFile.count, "should have removed the file record")
  end

end