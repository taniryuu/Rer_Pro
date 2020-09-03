class StepsController < ApplicationController
  before_action :set_step, only: %i(show edit update destroy)
  before_action :set_lead_and_user_by_lead_id

  # GET /steps
  # GET /steps.json
  def index
    @steps = Step.where(lead_id: @lead.id)
  end

  # GET /steps/1
  # GET /steps/1.json
  def show
  end

  # GET /steps/new
  def new
    @step = Step.new
  end

  # GET /steps/1/edit
  def edit
  end

  # POST /steps
  # POST /steps.json
  def create
    @step = Step.new(step_params)

    respond_to do |format|
      if @step.save
        format.html { redirect_to @step, notice: 'Step was successfully created.' }
        format.json { render :show, status: :created, location: @step }
      else
        format.html { render :new }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /steps/1
  # PATCH/PUT /steps/1.json
  def update
    respond_to do |format|
      if @step.update(step_params)
        format.html { redirect_to @step, notice: 'Step was successfully updated.' }
        format.json { render :show, status: :ok, location: @step }
      else
        format.html { render :edit }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /steps/1
  # DELETE /steps/1.json
  def destroy
    @step.destroy
    respond_to do |format|
      format.html { redirect_to steps_url, notice: 'Step was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_step
      @step = Step.find(params[:id])
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_lead_and_user_by_lead_id
      @lead = Lead.find(params[:lead_id])
      @user = User.find(@lead.user_id)
    end

    # Only allow a list of trusted parameters through.
    def step_params
      params.require(:step).permit(:lead_id, :name, :memo, :status, :order, :scheduled_complete_date, :completed_date, :completed_tasks_rate)
    end
end
