require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:post) { Post.create(title: "Test Title", body: "Test Body", author: "Test Author") }

  it "should be invalid without a body" do
    expect(Comment.new(body: nil, author: "Commenter", post: post)).not_to be_valid
  end

  it "should be invalid without an author" do
    expect(Comment.new(body: "Great post!", author: nil, post: post)).not_to be_valid
  end

  it "should be valid with all attributes" do
    expect(Comment.new(body: "Great post!", author: "Commenter", post: post)).to be_valid
  end

  it "should belong to a post" do
    comment = Comment.new(body: "Great post!", author: "Commenter", post: post)
    expect(comment.post).to eq(post)
  end
end