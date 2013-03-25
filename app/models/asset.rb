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

  def get
    #first find the asset within own assets
    asset = current_user.assets.find_by_id(params[:id])

    #if not found in own assets, check if the current_user has share access to the parent folder of the File
    asset ||= Asset.find(params[:id]) if current_user.has_share_access?(Asset.find_by_id(params[:id]).folder)

    if asset
      #Parse the URL for special characters first before downloading
      data = open(URI.parse(URI.encode(asset.uploaded_file.url)))
      send_data data, :filename => asset.uploaded_file_file_name
      #redirect_to asset.uploaded_file.url
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to root_url
    end
  end

end