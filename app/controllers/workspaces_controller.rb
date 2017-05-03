# frozen_string_literal: true
class WorkspacesController < ApplicationController
  before_action :set_workspace, only: [:show, :edit, :update, :destroy]

  def index
    if params[:q].blank?
      @workspaces = Workspace.all.order(name: :desc)
    else
      @workspaces = Workspace.where('name ilike ?', "%#{params[:q]}%").order(name: :desc)
    end

    respond_to do |format|
      format.html
      format.json { render json: @workspaces }
    end
  end

  def show
    if @workspace.views.empty?
      flash[:error] = "Unable to show workspace, there are no views defined"
      redirect_to workspaces_url
    else
      redirect_to [@workspace, @workspace.views.first]
    end
  end

  def new
    @workspace = Workspace.new
  end

  def edit
  end

  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.views.build(name: 'Default',
      center_lat: 64.5,
      center_lng: -146.5,
      zoom: 3.0,
      basemap: 'satellite-streets')

    respond_to do |format|
      if @workspace.save
        format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
        format.json { render :show, status: :created, location: @workspace }
      else
        format.html { render :new }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @workspace.update(workspace_params)
        format.html { redirect_to @workspace, notice: 'Workspace was successfully updated.' }
        format.json { render :show, status: :ok, location: @workspace }
      else
        format.html { render :edit }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @workspace.destroy
    respond_to do |format|
      format.html { redirect_to workspaces_url, notice: 'Workspace was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workspace
    @workspace = Workspace.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def workspace_params
    params.require(:workspace).permit(:name)
  end
end
