require 'rails_helper'

RSpec.describe Post, type: :model do
  it "should be invalid without a title" do
    expect(Post.new(title: nil, body: "Example", author: "John Doe")).not_to be_valid
  end

  it "should be invalid without a body" do
    expect(Post.new(title: "Example", body: nil, author: "John Doe")).not_to be_valid
  end

  it "should be invalid without an author" do
    expect(Post.new(title: "Example", body: "This is an example post.", author: nil)).not_to be_valid
  end

  it "should be valid with all attributes" do
    post = Post.new(title: "Valid Post", body: "This is a valid post body.", author: "Jane Doe")
    expect(post).to be_valid
  end

  it "should have a title" do
    post = Post.create(title: "Test Title", body: "Test Body", author: "Test Author")
    expect(post.title).to eq("Test Title")
  end

  it "should have a body" do
    post = Post.create(title: "Test Title", body: "Test Body", author: "Test Author")
    expect(post.body).to eq("Test Body")
  end

  it "should have an author" do
    post = Post.create(title: "Test Title", body: "Test Body", author: "Test Author")
    expect(post.author).to eq("Test Author")
  end
end
