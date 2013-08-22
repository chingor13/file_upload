require 'test_helper'

class MultipleUploadTest < CapybaraTest

  teardown do
    Email.destroy_all
    DbFile.destroy_all
  end

  test "can attach attachments on create" do
    email_count = Email.count
    file_count = DbFile.count

    visit new_email_path
    assert has_selector?("h1", text: "New Email")

    attach_file "email_attachments_file", File.expand_path("../../fixtures/avatar.jpeg", __FILE__)
    assert has_selector?(".file_upload ul li input[type=checkbox]", count: 1)
    attach_file "email_attachments_file", File.expand_path("../../fixtures/avatar.jpeg", __FILE__)
    assert has_selector?(".file_upload ul li input[type=checkbox]", count: 2)

    click_on "Create Email"

    # should have validation error on subject/message
    assert has_selector?(".error li")

    fill_in "Subject", with: "Hi there"
    fill_in "Message", with: "What are you up to?"

    click_on "Create Email"
    assert has_selector?("p", text: "Hi there")

    assert_equal(email_count + 1, Email.count)
    assert_equal(file_count + 2, DbFile.count)

    email = Email.last
    assert_equal(2, email.attachments.count)
  end

  test "can attach attachments, then change on create" do
    email_count = Email.count
    file_count = DbFile.count

    visit new_email_path
    assert has_selector?("h1", text: "New Email")

    fill_in "Subject", with: "Hi there"
    fill_in "Message", with: "What are you up to?"
    attach_file "email_attachments_file", File.expand_path("../../fixtures/avatar.jpeg", __FILE__)
    assert has_selector?(".file_upload ul li input[type=checkbox]", count: 1)

    attach_file "email_attachments_file", File.expand_path("../../fixtures/test_upload.txt", __FILE__)
    assert has_selector?(".file_upload ul li input[type=checkbox]", count: 2)
    uncheck 'avatar.jpeg'

    click_on "Create Email"
    assert has_selector?("p", text: "Hi there")

    assert_equal(email_count + 1, Email.count)
    assert_equal(file_count + 1, DbFile.count)

    email = Email.last
    assert_equal(1, email.attachments.count)
    file = email.attachments.first
    assert_equal("test_upload.txt", file.name)
  end

  test "can remove attachments" do
    email = Email.create({
      subject: "Fixture email subject",
      message: "Fixture email message",
      attachments: [
        DbFile.new({
          name: "pic.jpg",
          size: 112,
          content_type: "image/jpeg",
          data: "blah"
        })
      ]
    })
    assert email.persisted?, "sanity check"

    email_count = Email.count
    file_count = DbFile.count

    visit edit_email_path(email)
    assert has_selector?("h1", text: "Edit Email")

    uncheck "pic.jpg"
    click_on "Update Email"

    assert has_selector?("h2", text: "Attachments (0)")
    assert_equal(email_count, Email.count)
    assert_equal(file_count - 1, DbFile.count, "should have removed the file record")
  end

  test "can change attachments" do
    email = Email.create({
      subject: "Fixture email subject",
      message: "Fixture email message",
      attachments: [
        DbFile.new({
          name: "pic.jpg",
          size: 112,
          content_type: "image/jpeg",
          data: "blah"
        })
      ]
    })
    assert email.persisted?, "sanity check"

    email_count = Email.count
    file_count = DbFile.count

    visit edit_email_path(email)
    assert has_selector?("h1", text: "Edit Email")

    uncheck "pic.jpg"
    attach_file "email_attachments_file", File.expand_path("../../fixtures/test_upload.txt", __FILE__)
    assert has_selector?(".file_upload ul li input[type=checkbox]", count: 2)
    click_on "Update Email"

    assert has_selector?("h2", text: "Attachments (1)")
    assert_equal(email_count, Email.count)
    assert_equal(file_count, DbFile.count, "should have removed the file record and created a new one")

    file = DbFile.last
    assert_equal("test_upload.txt", file.name)
  end

end