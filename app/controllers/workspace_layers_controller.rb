class WorkspaceLayersController < ApplicationController
  before_action :set_workspace_layer, only: [:show, :edit, :update, :destroy]

  # GET /workspace_layers
  # GET /workspace_layers.json
  def index
    @workspace_layers = WorkspaceLayer.all
  end

  # GET /workspace_layers/1
  # GET /workspace_layers/1.json
  def show
  end

  # GET /workspace_layers/new
  def new
    @workspace_layer = WorkspaceLayer.new
  end

  # GET /workspace_layers/1/edit
  def edit
  end

  # POST /workspace_layers
  # POST /workspace_layers.json
  def create
    @workspace_layer = WorkspaceLayer.new(workspace_layer_params)

    respond_to do |format|
      if @workspace_layer.save
        format.html { redirect_to @workspace_layer, notice: 'Workspace layer was successfully created.' }
        format.json { render :show, status: :created, location: @workspace_layer }
      else
        format.html { render :new }
        format.json { render json: @workspace_layer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workspace_layers/1
  # PATCH/PUT /workspace_layers/1.json
  def update
    respond_to do |format|
      if @workspace_layer.update(workspace_layer_params)
        format.html { redirect_to @workspace_layer, notice: 'Workspace layer was successfully updated.' }
        format.json { render :show, status: :ok, location: @workspace_layer }
      else
        format.html { render :edit }
        format.json { render json: @workspace_layer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspace_layers/1
  # DELETE /workspace_layers/1.json
  def destroy
    @workspace_layer.destroy
    respond_to do |format|
      format.html { redirect_to workspace_layers_url, notice: 'Workspace layer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workspace_layer
      @workspace_layer = WorkspaceLayer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workspace_layer_params
      params.require(:workspace_layer).permit(:workspace_id, :layer_id, :position)
    end
end
