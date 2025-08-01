require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let!(:sample_post) { Post.create(title: "Sample Post", body: "This is a sample post.", author: "John Doe") }
  let(:valid_attributes) { { title: "New Post", body: "New post body", author: "Jane Doe" } }
  let(:invalid_attributes) { { title: "", body: "", author: "" } }
  let(:partial_invalid_attributes) { { title: "Valid Title", body: "", author: "Jane Doe" } }

  describe "GET #index" do
    it "should return a success response and list the posts" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:posts)).to include(sample_post)
    end

    it "should return an empty array when no posts exist" do
      Post.destroy_all
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:posts)).to be_empty
    end

    it "should return posts in JSON format" do
      get :index, format: :json
      expect(response.media_type).to eq("application/json")
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
    end

    it "returns all posts in correct order" do
      newer_post = Post.create(title: "Newer Post", body: "Newer content", author: "Author")
      get :index
      posts = assigns(:posts)
      expect(posts.count).to eq(2)
      expect(posts).to include(sample_post, newer_post)
    end

    it "includes all required fields in JSON response" do
      get :index, format: :json
      parsed_response = JSON.parse(response.body)
      first_post = parsed_response.first
      expect(first_post).to have_key("id")
      expect(first_post).to have_key("title")
      expect(first_post).to have_key("body")
      expect(first_post).to have_key("author")
      expect(first_post).to have_key("created_at")
      expect(first_post).to have_key("updated_at")
    end
  end

  describe "GET #show" do
    it "should return a success response" do
      get :show, params: { id: sample_post.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:post)).to eq(sample_post)
    end

    it "should return the post in JSON format" do
      get :show, params: { id: sample_post.id }, format: :json
      expect(response.media_type).to eq("application/json")
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["title"]).to eq(sample_post.title)
      expect(parsed_response["body"]).to eq(sample_post.body)
      expect(parsed_response["author"]).to eq(sample_post.author)
    end

    it "should return 404 for non-existent post" do
      expect {
        get :show, params: { id: 999999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Post" do
        expect {
          post :create, params: { post: valid_attributes }
        }.to change(Post, :count).by(1)
      end

      it "renders a JSON response with the new post" do
        post :create, params: { post: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.media_type).to eq("application/json")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Post" do
        expect {
          post :create, params: { post: invalid_attributes }
        }.to change(Post, :count).by(0)
      end

      it "renders a JSON response with errors for the new post" do
        post :create, params: { post: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.media_type).to eq("application/json")
      end

      it "returns specific validation errors" do
        post :create, params: { post: invalid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("title")
        expect(parsed_response).to have_key("body")
        expect(parsed_response).to have_key("author")
      end

      it "handles partial validation errors" do
        post :create, params: { post: partial_invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("body")
        expect(parsed_response).not_to have_key("title")
        expect(parsed_response).not_to have_key("author")
      end
    end

    context "CUID generation" do
      it "creates post with CUID as ID" do
        post :create, params: { post: valid_attributes }
        created_post = Post.last
        expect(created_post.id).to be_present
        expect(created_post.id).to match(/^c[a-z0-9]{24}$/) # CUID pattern
      end

      it "ignores unpermitted parameters" do
        dangerous_params = valid_attributes.merge(
          admin: true,
          created_at: 1.year.ago,
          id: "custom_id"
        )
        post :create, params: { post: dangerous_params }
        created_post = Post.last
        expect(created_post.title).to eq(valid_attributes[:title])
        expect(created_post.body).to eq(valid_attributes[:body])
        expect(created_post.author).to eq(valid_attributes[:author])
        # These should not be set
        expect(created_post).not_to respond_to(:admin)
        expect(created_post.id).not_to eq("custom_id")
      end

      it "returns the created post data in response" do
        post :create, params: { post: valid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["title"]).to eq(valid_attributes[:title])
        expect(parsed_response["body"]).to eq(valid_attributes[:body])
        expect(parsed_response["author"]).to eq(valid_attributes[:author])
        expect(parsed_response).to have_key("id")
        expect(parsed_response).to have_key("created_at")
        expect(parsed_response).to have_key("updated_at")
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title", body: "Updated body" } }

      it "updates the requested post" do
        patch :update, params: { id: sample_post.id, post: new_attributes }
        sample_post.reload
        expect(sample_post.title).to eq("Updated Title")
        expect(sample_post.body).to eq("Updated body")
      end

      it "renders a JSON response with the post" do
        patch :update, params: { id: sample_post.id, post: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the post" do
        patch :update, params: { id: sample_post.id, post: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.media_type).to eq("application/json")
      end

      it "returns specific validation errors on update" do
        patch :update, params: { id: sample_post.id, post: invalid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("title")
        expect(parsed_response).to have_key("body")
        expect(parsed_response).to have_key("author")
      end

      it "does not update the post with invalid data" do
        original_title = sample_post.title
        patch :update, params: { id: sample_post.id, post: { title: "" } }
        sample_post.reload
        expect(sample_post.title).to eq(original_title)
      end
    end

    it "returns 404 for non-existent post" do
      expect {
        patch :update, params: { id: 999999, post: valid_attributes }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested post" do
      expect {
        delete :destroy, params: { id: sample_post.id }
      }.to change(Post, :count).by(-1)
    end

    it "returns success response" do
      delete :destroy, params: { id: sample_post.id }
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent post" do
      expect {
        delete :destroy, params: { id: 999999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
