module TasksHelper
  def step_name(step)
    "<STEP#{step.order}>#{step.name}"
  end
end
