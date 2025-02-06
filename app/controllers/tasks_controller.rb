class TasksController < ApplicationController
    before_action :set_checklist
    before_action :set_task, only: [:update, :destroy]
  
    def create
      @task = @checklist.tasks.build(task_params)
      @task.completed = false # Ensure default is false
      if @task.save
        redirect_to property_checklist_path(@checklist.property, @checklist), notice: 'Task added.'
      else
        redirect_to property_checklist_path(@checklist.property, @checklist), alert: 'Task could not be added.'
      end
    end
    
    def update
      if @task.update(task_params)
        redirect_to property_checklist_path(@checklist.property, @checklist), notice: 'Task updated.'
      else
        redirect_to property_checklist_path(@checklist.property, @checklist), alert: 'Task could not be updated.'
      end
    end
  
    def destroy
      @task.destroy
      redirect_to property_checklist_path(@checklist.property, @checklist), notice: 'Task deleted.'
    end
  
    private
  
    def set_checklist
      @checklist = Checklist.find(params[:checklist_id])
    end
  
    def set_task
      @task = @checklist.tasks.find(params[:id])
    end
  
    def task_params
      params.require(:task).permit(:name, :completed)
    end
  end
  