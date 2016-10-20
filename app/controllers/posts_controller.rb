class PostsController < ApplicationController
  def index
    @posts = Post.search(params[:search])
  end

  def new
    @post = Post.new
    @title = 'Create a new post'
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      redirect_to post_path(@post.id) # /posts/:id
    else
      render :new
    end
  end

  def show
    @post = Post.find(params[:id]) # pulls id from /posts/:id in url
  end

  def edit
    @post = Post.find(params[:id])
    if current_user == @post.user
      render :edit
    else
      flash[:alert] = "Access denied!"
      redirect_to root_path
    end
  end

  def update
    @post = Post.find(params[:id])
    if current_user == @post.user && @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if @post.user == current_user
      @post.destroy
    else
      flash[:alert] = "Access denied!"
    end
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :cost, :body, :image, :longitude, :latitude, :address, :user_id)
  end
end
