class DbFilesController < ApplicationController

  def show
    @db_file = DbFile.find(params[:id])
    send_data @db_file.data, type: @db_file.content_type, disposition: "inline"
  end

end