class CommentsController < ApplicationController
  def create
    job = Job.find(params[:job_id])
    job.comments.create(comment_params)
    redirect_to select_job_path(job)
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy

    respond_to do |format|
      format.html { redirect_to select_job_path(comment.job) }
      format.js
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:user_id, :body, :job_id)
    end
end
