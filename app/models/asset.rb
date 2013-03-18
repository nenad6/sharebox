class Asset < ActiveRecord::Base
  attr_accessible :user_id, :uploaded_file, :folder_id

  belongs_to :user
  belongs_to :folder

  has_attached_file :uploaded_file,
                    :url => "/assets/get/:id",
                    :path => "Rails_root/assets/:id/:basename.:extension"

  validates_attachment_size :uploaded_file, :less_than => 10.megabytes
  validates_attachment_presence :uploaded_file

  def file_name
    uploaded_file_file_name
  end

  def file_size
    uploaded_file_file_size
  end

  def new
    @asset = current_user.assets.build
    if params[:folder_id] #if we want to upload a file inside another folder
      @current_folder = current_user.folders.find(params[:folder_id])
      @asset.folder_id = @current_folder.id
    end
  end

  def create

    @asset = current_user.assets.build(params[:asset])
    if @asset.save
      flash[:notice] = "Successfully uploaded the file."

      if @asset.folder #checking if we have a parent folder for this file
        redirect_to browse_path(@asset.folder)  #then we redirect to the parent folder
      else
        redirect_to root_url
      end
    else
      render :action => 'new'
    end
  end

  def destroy
    @asset = current_user.assets.find(params[:id])
    @parent_folder = @asset.folder #grabbing the parent folder before deleting the record
    @asset.destroy
    flash[:notice] = "Successfully deleted the file."

    #redirect to a relevant path depending on the parent folder
    if @parent_folder
      redirect_to browse_path(@parent_folder)
    else
      redirect_to root_url
    end
  end

end