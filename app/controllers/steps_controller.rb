class StepsController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_step, only: %i(show edit update destroy)
  before_action :set_lead_and_user_by_lead_id
  # フィルター（アクセス権限）
  before_action :correct_user, except: %i(index show)
  # 後処理
  after_action :sort_order, only: %i(destroy index)


  # GET /steps
  # GET /steps.json
  def index
    @steps = @lead.steps.all.order(:order)
  end

  # GET /steps/1
  # GET /steps/1.json
  def show
  end

  # GET /steps/new
  def new
    @step = @lead.steps.new
  end

  # GET /steps/1/edit
  def edit
  end

  # POST /steps
  # POST /steps.json
  def create
    @step = @lead.steps.new(step_params)
    respond_to do |format|
      if save_and_errors_of(@step).blank?
        format.html { redirect_to [@lead, @step], notice: 'Step was successfully created.' }
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
      if update_and_errors_of(@step).blank?
        format.html { redirect_to [@lead, @step], notice: 'Step was successfully updated.' }
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
    update_steps_rate(@lead)
    respond_to do |format|
      format.html { redirect_to lead_steps_url, notice: 'Step was successfully destroyed.' }
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
    
    # クリエイト処理
    def save_and_errors_of(step)
      errors = []
      ActiveRecord::Base.transaction do
        prepare_order(@lead.steps.count + 1, step.order)
        unless step.save
          errors << step.errors.full_messages
        end
        # step.update_attribute(:completed_date, "") unless step.status == "completed"
        step.update_attribute(:status, "completed") if step.completed_date.present?
        update_completed_tasks_rate(step)
        update_steps_rate(@lead)
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end
    
    # アップデート処理
    def update_and_errors_of(step)
      errors = []
      ActiveRecord::Base.transaction do
        prepare_order(step.order, params[:step][:order].to_i)
        unless step.update(step_params)
          errors << step.errors.full_messages
        end
        step.update_attribute(:status, "completed") if step.completed_date.present?
        update_completed_tasks_rate(step)
        update_steps_rate(@lead)
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end
    
    # 〇番(pre_order)だったデータを避難し、×番(new_order)を空けておく処理
    def prepare_order(pre_order, new_order)
      unless pre_order == new_order
        # Updateの場合、pre_orderを最大値+1に一時避難
        # debugger
        @lead.steps.find_by(order: pre_order).update_attribute(:order, @lead.steps.count + 1) unless @step.new_record?
        if pre_order < new_order
          # (pre_order + 1)..new_orderを前にずらす処理
          ((pre_order + 1)..new_order).each do |order_num|
            step = @lead.steps.find_by(order: order_num)
            step.update_attribute(:order, order_num - 1)
          end
        else
          # new_order..(pre_order - 1)の順番を後ろにずらす処理
          (new_order..(pre_order - 1)).reverse_each do |order_num|
            step = @lead.steps.find_by(order: order_num)
            step.update_attribute(:order, order_num + 1)
          end
        end
      end
    end
    
    # 順番をチェックし、空があったら詰める処理
    def sort_order
      if @lead.steps.find_by(order: @lead.steps.count + 1).present?
#        debugger
        (1..@lead.steps.count).each do |order_num|
          if @lead.steps.find_by(order: order_num).blank?
            step = @lead.steps.find_by(order: order_num + 1)
            step.update_attribute(:order, order_num)
          end
        end
      end
    end
    
end
