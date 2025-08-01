require 'rails_helper'

RSpec.describe "Posts API", type: :request do
  let(:post_params) do
    { post: { title: "Sample Post", body: "This is a sample post.", author: "John Doe" } }
  end

  let(:post_record) do
    Post.create(title: "Sample Post", body: "This is a sample post.", author: "John Doe")
  end

  def create_post
    post "/posts", params: post_params
  end

  it "should be create a post" do
    create_post
    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)["title"]).to eq("Sample Post")
  end

  it "should return a list of posts" do
    get "/posts"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_an_instance_of(Array)
  end

  it "should return a single post" do
    create_post
    get "/posts/#{post_record.id}"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["title"]).to eq("Sample Post")
  end

  it "should update a post" do
    create_post
    put "/posts/#{post_record.id}", params: { post: { title: "Updated Title" } }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["title"]).to eq("Updated Title")
  end

  it "should delete a post" do
    create_post
    delete "/posts/#{post_record.id}"
    expect(response).to have_http_status(:no_content)
    expect(Post.exists?(post_record.id)).to be_falsey
  end
end
