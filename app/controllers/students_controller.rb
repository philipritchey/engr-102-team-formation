class StudentsController < ApplicationController
  def index
    @students = Student.all
  end

  def show
    @student = Student.find_by(uin: params[:uin])
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to @student, notice: "Student was successfully created."
    else
      render :new
    end
  end

  def edit
    @student = Student.find_by(uin: params[:uin])
  end

  def update
    @student = Student.find_by(uin: params[:uin])
    if @student.update(student_params)
      redirect_to @student, notice: "Student was successfully updated."
    else
      render :edit
    end
  end

  private

  def student_params
    params.require(:student).permit(:uin, :name, :email, :section)
  end
end
