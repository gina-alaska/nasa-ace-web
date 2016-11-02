class ViewLayersController < ApplicationController
  before_action :set_view_layer, only: [:show, :edit, :update, :destroy]

  # GET /workspace_layers
  # GET /workspace_layers.json
  def index
    @view_layers = ViewLayer.all
  end

  # GET /workspace_layers/1
  # GET /workspace_layers/1.json
  def show
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
  def create
    @view_layer = ViewLayer.new(view_layer_params)

    respond_to do |format|
      if @view_layer.save
        format.html { redirect_to @view_layer, notice: 'View layer was successfully created.' }
        format.json { render :show, status: :created, location: @view_layer }
      else
        format.html { render :new }
        format.json { render json: @view_layer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workspace_layers/1
  # PATCH/PUT /workspace_layers/1.json
  def update
    respond_to do |format|
      if @view_layer.update(view_layer_params)
        format.html { redirect_to @view_layer, notice: 'View layer was successfully updated.' }
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
      format.html { redirect_to view_layers_url, notice: 'View layer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_view_layer
    @view_layer = ViewLayer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def view_layer_params
    params.require(:view_layer).permit(:view_id, :layer_id, :position)
  end
end
