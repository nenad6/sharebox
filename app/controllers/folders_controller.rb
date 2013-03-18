class FoldersController < ApplicationController
  before_filter :authenticate_user!
  def index
    @folders = current_user.folders
  end

  def show
    @folder = current_user.folders.find(params[:id])
  end

  def new
    @folder = current_user.folders.new
  end

  def create
    @folder = current_user.folders.new(params[:folder])
    if @folder.save
      redirect_to @folder, :notice => "Successfully created folder."
    else
      render :action => 'new'
    end
  end

  def edit
    @folder = current_user.folders.find(params[:folder_id])
    @current_folder = @folder.parent    #this is just for breadcrumbs
  end

  def update
    @folder = current_user.folders.find(params[:id])
    if @folder.update_attributes(params[:folder])
      redirect_to @folder, :notice  => "Successfully updated folder."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @folder = current_user.folders.find(params[:id])
    @parent_folder = @folder.parent #grabbing the parent folder

    #this will destroy the folder along with all the contents inside
    #sub folders will also be deleted too as well as all files inside
    @folder.destroy
    flash[:notice] = "Successfully deleted the folder and all the contents inside."

    #redirect to a relevant path depending on the parent folder
    if @parent_folder
      redirect_to browse_path(@parent_folder)
    else
      redirect_to root_url
    end
  end
end
