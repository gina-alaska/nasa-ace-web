# frozen_string_literal: true
class ViewLayersController < ApplicationController
  before_action :set_view_layer

  # GET /workspace_layers
  # GET /workspace_layers.json
  def index
    @view_layers = ViewLayer.all
  end

  # GET /workspace_layers/1
  # GET /workspace_layers/1.json
  def show
    respond_to do |format|
      format.html { render layout: false }
      format.json
    end
  end

  # GET /workspace_layers/new
  def new
    @view_layer = ViewLayer.new
  end

  # GET /workspace_layers/1/edit
  def edit
  end

  # POST /workspace_layers
  # POST /workspace_layers.json
  # rubocop:disable Metrics/AbcSize
  def create
    @view_layer = @view.view_layers.build(view_layer_params)

    respond_to do |format|
      if @view_layer.save
        ActionCable.server.broadcast "workspaces:workspace_#{@workspace.id}_#{@view.id}",
                                     command: 'ws.layers.add',
                                     name: @view_layer.layer.name,
                                     url: workspace_view_view_layer_path(@workspace, @view, @view_layer)

        format.js { head :created, location: workspace_view_view_layer_path(@workspace, @view, @view_layer) }
        format.html { redirect_to [@workspace, @view, @view_layer], notice: 'View layer was successfully created.' }
        format.json { render :show, status: :created, location: @view_layer }
      else
        format.html { render :new }
        format.json { render json: @view_layer.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # PATCH/PUT /workspace_layers/1
  # PATCH/PUT /workspace_layers/1.json
  def update
    respond_to do |format|
      if @view_layer.update(view_layer_params)
        format.html { redirect_to [@workspace, @view, @view_layer], notice: 'View layer was successfully updated.' }
        format.json { render :show, status: :ok, location: @view_layer }
      else
        format.html { render :edit }
        format.json { render json: @view_layer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspace_layers/1
  # DELETE /workspace_layers/1.json
  def destroy
    @view_layer.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to workspace_view_url(@workspace, @view), notice: 'View layer was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_view_layer
    @workspace = Workspace.find(params[:workspace_id])
    @view = @workspace.views.find(params[:view_id])
    @view_layer = @view.view_layers.find(params[:id]) if params[:id].present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def view_layer_params
    params.require(:view_layer).permit(:view_id, :layer_id, :position)
  end
end
