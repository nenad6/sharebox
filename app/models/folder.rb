class Folder < ActiveRecord::Base
  acts_as_tree

  attr_accessible :name, :parent_id, :user_id

  belongs_to :user

  has_many :assets, :dependent => :destroy

  has_many :shared_folders, :dependent => :destroy

  def shared?
    !self.shared_folders.empty?
  end

  attr_accessible :user_id, :uploaded_file, :folder_id

  belongs_to :folder
  has_many :assets, :dependent => :destroy

  def new
    @folder = current_user.folders.new
    #if there is "folder_id" param, we know that we are under a folder, thus, we will essentially create a subfolder
    if params[:folder_id] #if we want to create a folder inside another folder

      #we still need to set the @current_folder to make the buttons working fine
      @current_folder = current_user.folders.find(params[:folder_id])

      #then we make sure the folder we are creating has a parent folder which is the @current_folder
      @folder.parent_id = @current_folder.id
    end
  end

  def create
    @folder = current_user.folders.new(params[:folder])
    if @folder.save
      flash[:notice] = "Successfully created folder."

      if @folder.parent #checking if we have a parent folder on this one
        redirect_to browse_path(@folder.parent)  #then we redirect to the parent folder
      else
        redirect_to root_url #if not, redirect back to home page
      end
    else
      render :action => 'new'
    end
  end


end