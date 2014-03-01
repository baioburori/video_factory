# -*- encoding: utf-8 -*-

class ImageUrlsController < ApplicationController
  # GET /image_urls
  # GET /image_urls.json
  def index
    @image_urls = ImageUrl.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @image_urls }
    end
  end

  # GET /image_urls/1
  # GET /image_urls/1.json
  def show
    @image_url = ImageUrl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @image_url }
    end
  end

  # GET /image_urls/new
  # GET /image_urls/new.json
  def new
    @image_url = ImageUrl.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image_url }
    end
  end

  # GET /image_urls/1/edit
  def edit
    @image_url = ImageUrl.find(params[:id])
  end

  # POST /image_urls
  # POST /image_urls.json
  def create
    @image_url = ImageUrl.new(params[:image_url])

    respond_to do |format|
      if @image_url.save
        format.html { redirect_to @image_url, notice: 'Image url was successfully created.' }
        format.json { render json: @image_url, status: :created, location: @image_url }
      else
        format.html { render action: "new" }
        format.json { render json: @image_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /image_urls/1
  # PUT /image_urls/1.json
  def update
    @image_url = ImageUrl.find(params[:id])

    respond_to do |format|
      if @image_url.update_attributes(params[:image_url])
        format.html { redirect_to @image_url, notice: 'Image url was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_urls/1
  # DELETE /image_urls/1.json
  def destroy
    @image_url = ImageUrl.find(params[:id])
    @image_url.destroy

    respond_to do |format|
      format.html { redirect_to image_urls_url }
      format.json { head :no_content }
    end
  end
end
