require 'rails_helper'

RSpec.describe "Comments API", type: :request do
  let(:post_record) do
    Post.create(title: "Sample Post", body: "This is a sample post.", author: "Author Name")
  end

  let(:comment_params) do
    { comment: { body: "Great post!", author: "Commenter" } }
  end

  def create_comment(post)
    post "/posts/#{post.id}/comments", params: comment_params
  end

  it "should creates a comment" do
    create_comment(post_record)
    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)["body"]).to eq("Great post!")
  end

  it "should returns a list of comments for a post" do
    create_comment(post_record)
    get "/posts/#{post_record.id}/comments"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_an(Array)
    expect(JSON.parse(response.body).first["body"]).to eq("Great post!")
  end

  it "should return a single comment" do
    create_comment(post_record)
    get "/comments/#{Comment.last.id}"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["body"]).to eq("Great post!")
  end

  it "should update a comment" do
    create_comment(post_record)
    comment = Comment.last
    put "/comments/#{comment.id}", params: { comment: { body: "Updated comment" } }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["body"]).to eq("Updated comment")
  end

end