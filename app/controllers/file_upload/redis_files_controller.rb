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
    respond_to do |format|
      format.json {
        render json: @redis_file.to_json
      }
      format.html
    end
  end

  def preview
    @redis_file = FileUpload::RedisFile.find(params[:id])
    send_data @redis_file.data, type: @redis_file.type, disposition: "inline"
  end

  def destroy
    @redis_file = FileUpload::RedisFile.find(params[:id])
    @redis_file.destroy
    respond_to do |format|
      format.json {
        render json: {
          status: "OK"
        }
      }
      format.html
    end
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
          files: files.map(&:to_json)
        }
      }
    end
  end
end