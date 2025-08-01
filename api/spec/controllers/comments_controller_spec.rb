require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:sample_post) { Post.create(title: "Sample Post", body: "This is a sample post.", author: "John Doe") }
  let!(:comment) { Comment.create(body: "Test Comment", author: "Test Author", post: sample_post) }
  
  describe "GET #show" do
    it "should return a success response" do
      get :show, params: { id: comment.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:comment)).to eq(comment)
    end

    it "should return the comment in JSON format" do
      get :show, params: { id: comment.id }, format: :json
      expect(response.media_type).to eq("application/json")
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["body"]).to eq(comment.body)
      expect(parsed_response["author"]).to eq(comment.author)
    end

    it "should return 404 for non-existent comment" do
      expect {
        get :show, params: { id: "nonexistent" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { body: "New Comment", author: "Jane Doe" } }
    let(:invalid_attributes) { { body: "", author: "" } }
    let(:partial_invalid_attributes) { { body: "", author: "Jane Doe" } }

    context "with valid parameters" do
      it "creates a new Comment" do
        expect {
          post :create, params: { post_id: sample_post.id, comment: valid_attributes }
        }.to change(Comment, :count).by(1)
      end

      it "renders a JSON response with the new comment" do
        post :create, params: { post_id: sample_post.id, comment: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.media_type).to eq("application/json")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Comment" do
        expect {
          post :create, params: { post_id: sample_post.id, comment: invalid_attributes }
        }.to change(Comment, :count).by(0)
      end

      it "renders a JSON response with errors for the new comment" do
        post :create, params: { post_id: sample_post.id, comment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.media_type).to eq("application/json")
      end

      it "returns specific validation errors" do
        post :create, params: { post_id: sample_post.id, comment: invalid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["errors"]).to have_key("body")
        expect(parsed_response["errors"]).to have_key("author")
      end

      it "handles partial validation errors" do
        post :create, params: { post_id: sample_post.id, comment: partial_invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["errors"]).to have_key("body")
        expect(parsed_response["errors"]).not_to have_key("author")
      end
    end
  end

  describe "PATCH/PUT #update" do
    let(:new_attributes) { { body: "Updated body", author: "Updated Author" } }
    let(:invalid_attributes) { { body: "", author: "" } }

    context "with valid parameters" do
      it "updates the requested comment" do
        patch :update, params: { id: comment.id, comment: new_attributes }
        comment.reload
        expect(comment.body).to eq("Updated body")
        expect(comment.author).to eq("Updated Author")
      end

      it "renders a JSON response with the comment" do
        patch :update, params: { id: comment.id, comment: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the comment" do
        patch :update, params: { id: comment.id, comment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.media_type).to eq("application/json")
      end

      it "returns specific validation errors on update" do
        patch :update, params: { id: comment.id, comment: invalid_attributes }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["errors"]).to have_key("body")
        expect(parsed_response["errors"]).to have_key("author")
      end

      it "does not update the comment with invalid data" do
        original_body = comment.body
        patch :update, params: { id: comment.id, comment: { body: "" } }
        comment.reload
        expect(comment.body).to eq(original_body)
      end
    end

    it "returns 404 for non-existent comment" do
      expect {
        patch :update, params: { id: "nonexistent", comment: new_attributes }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested comment" do
      expect {
        delete :destroy, params: { id: comment.id }
      }.to change(Comment, :count).by(-1)
    end

    it "returns success response" do
      delete :destroy, params: { id: comment.id }
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent comment" do
      expect {
        delete :destroy, params: { id: "nonexistent" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end