require 'swagger_helper'
require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:post_params) do
    { post: { title: "Sample Post", body: "This is a sample post.", author: "John Doe" } }
  end

  let(:post_record) do
    Post.create(title: "Sample Post", body: "This is a sample post.", author: "John Doe")
  end

  def create_post
    post "/posts", params: post_params
  end

  path '/posts' do
    get 'Lists all posts' do
      tags ['Posts']
      produces 'application/json'
      response '200', 'Posts found' do
        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to be_an_instance_of(Array)
          expect(JSON.parse(response.body).first['title']).to eq("Sample Post")
        end
      end
    end

    post 'Creates a post' do
      tags ['Posts']
      consumes 'application/json'
      parameter name: 'post', in: :body, schema: {
        type: :object,
        properties: {
          title:  { type: :string },
          body:   { type: :string },
          author: { type: :string }
        },
        required: ['title', 'body', 'author']
      }

      response '201', 'Post created' do
        run_test! do
          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)["title"]).to eq("Sample Post")
        end
      end
    end
  end

  path '/posts/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Post ID'

    get 'Retrieves a post' do
      tags ['Posts']
      produces 'application/json'

      response '200', 'Post found' do
        let(:id) { post_record.id }
        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)["title"]).to eq("Sample Post")
        end
      end

      response '404', 'Post not found' do
        let(:id) { 9999 }
        run_test!
      end
    end

    put 'Updates a post' do
      tags ['Posts']
      consumes 'application/json'
      parameter name: 'post', in: :body, schema: {
        type: :object,
        properties: {
          title:  { type: :string },
          body:   { type: :string },
          author: { type: :string }
        },
        required: ['title', 'body', 'author']
      }
      response '200', 'Post updated' do
        let(:id) { post_record.id }
        let(:post_params) { { post: { title: "Updated Post", body: "Updated content", author: "Jane Doe" } } }
        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)["title"]).to eq("Updated Post")
        end
      end
    end

    delete 'Deletes a post' do
      tags ['Posts']
      response '204', 'Post deleted' do
        let(:id) { post_record.id }
        run_test! do
          expect(response).to have_http_status(:no_content)
        end
      end

      response '404', 'Post not found' do
        let(:id) { 9999 }
        run_test!
      end
    end
  end

  path '/posts/{id}/comments' do

    get 'Lists comments for a post' do
      tags 'Comments'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string
      response '200', 'Comments found' do
        let(:id) { post_record.id }
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :string },
              post_id: { type: :string },
              author: { type: :string },
              body: { type: :string }
            }
          }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to be_an_instance_of(Array)
        end
      end
    end

    post 'Creates a comment on a post' do
      tags 'Comments'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string
      request_body_example value: {
        author: "Jane Doe",
        body: "This is a comment."
      }

      response '201', 'Comment created' do
        schema type: :object,
          properties: {
            id: { type: :string },
            post_id: { type: :string },
            author: { type: :string },
            body: { type: :string }
          }
        run_test! do
          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)["body"]).to eq("This is a comment.")
        end
      end
    end

    path '/posts/{id}/comments/{comment_id}' do
      parameter name: 'id', in: :path, type: :string, description: 'Post ID'
      parameter name: 'comment_id', in: :path, type: :string, description: 'Comment ID'

      get 'Retrieves a comment' do
        tags 'Comments'
        produces 'application/json'

        response '200', 'Comment found' do
          let(:id) { post_record.id }
          let(:comment_id) { post_record.comments.first.id }
          run_test! do
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)["body"]).to eq("This is a comment.")
          end
        end

        response '404', 'Comment not found' do
          let(:id) { post_record.id }
          let(:comment_id) { 9999 }
          run_test!
        end
      end

      put 'Updates a comment' do
        tags 'Comments'
        produces 'application/json'
        request_body_example value: {
          author: "Jane Doe",
          body: "This is an updated comment."
        }
        response '200', 'Comment updated' do
          let(:id) { post_record.id }
          let(:comment_id) { post_record.comments.first.id }
          run_test! do
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)["body"]).to eq("This is an updated comment.")
          end
        end
      end

      delete 'Deletes a comment' do
        tags 'Comments'
        response '204', 'Comment deleted' do
          let(:id) { post_record.id }
          let(:comment_id) { post_record.comments.first.id }
          run_test! do
            expect(response).to have_http_status(:no_content)
          end
        end

        response '404', 'Comment not found' do
          let(:id) { post_record.id }
          let(:comment_id) { 9999 }
          run_test!
        end
      end
    end
  end
end
