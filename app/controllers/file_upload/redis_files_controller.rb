class FileUpload::RedisFilesController < ApplicationController

  def index
  end

  def new
    @redis_file = FileUpload::RedisFile.new
  end

  def create
    @redis_file = FileUpload::RedisFile.new(params[:redis_file])
    if @redis_file.save
      redirect_to @redis_file
    else
      render :new
    end
  end

  def show
    @redis_file = FileUpload::RedisFile.find(params[:id])
  end

  def destroy
    @redis_file = FileUpload::RedisFile.find(params[:id])
    @redis_file.destroy
  end

  def bulk
    unless params[:redis_files]
      render status: 400, json: { files: [{error: 'No files uploaded.'}] }
      return
    end

    files = Array(params.require(:redis_files)).map do |file|
      f = FileUpload::RedisFile.new({
        file_io: file[:data]
      })
      f.save
      f
    end
    respond_to do |format|
      format.js {
        render json: {
          files: files.map{|file| file.to_json}
        }
      }
    end
  end
end