# frozen_string_literal: true
class ViewsController < ApplicationController
  before_action :set_workspace
  before_action :set_view, only: [:show, :edit, :update, :destroy, :duplicate]

  # GET /workspaces
  # GET /workspaces.json
  def index
    @views = @workspace.views.all
  end

  # GET /workspaces/1
  # GET /workspaces/1.json
  def show
    # WorkspacesChannel.broadcast_to "workspace_#{@workspace.id}", { test: 'testing' }
  end

  # GET /workspaces/new
  def new
    @view = @workspace.views.build
  end

  # GET /workspaces/1/edit
  def edit
  end

  # POST /workspaces
  # POST /workspaces.json
  def create
    @view = @workspace.views.build(view_params)

    respond_to do |format|
      if @view.save
        @view.layers = Layer.all
        format.html { redirect_to workspace_view_path(@workspace, @view), notice: 'View was successfully created.' }
        format.json { render :show, status: :created, location: @view }
      else
        format.html { render :new }
        format.json { render json: @view.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workspaces/1
  # PATCH/PUT /workspaces/1.json
  def update
    respond_to do |format|
      if @view.update(view_params)
        format.html { redirect_to workspace_view_path(@workspace, @view), notice: 'View was successfully updated.' }
        format.json { render :show, status: :ok, location: @view }
      else
        format.html { render :edit }
        format.json { render json: @view.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspaces/1
  # DELETE /workspaces/1.json
  def destroy
    @view.destroy
    respond_to do |format|
      format.html { redirect_to workspaces_url, notice: 'View was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def duplicate
    new_view = @workspace.views.new(name: @view.name+'-duplicate', center_lat: @view.center_lat, center_lng: @view.center_lng, zoom: @view.zoom, basemap: @view.basemap)
    active_layers = @view.view_layers.where(active: true).collect{ |layer| layer.layer }
    
    respond_to do |format|
      if new_view.save
        new_view.layers << active_layers
        format.html { redirect_to edit_workspace_view_path(@workspace, new_view), notice: 'View was successfully created.' }
        format.json { render :show, status: :created, location: new_view }
      else
        format.html { render :edit }
        format.json { render json: new_view.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  end

  def set_view
    @view = @workspace.views.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def view_params
    params.require(:view).permit(:name, :center_lat, :center_lng, :zoom, :presenter_id, :basemap)
  end
end
