class AttendancesController < ApplicationController
  # 勤怠編集に通して良いレコードの絞り込みにヘルパーメソッドを利用します ⇨attendances_helper
  include AttendancesHelper
  
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      if attendances_invalid? # 勤怠編集に通して良いレコードを絞り込みします ⇨attendances_helper
        attendances_params.each do |id, item| # データベースの操作を保障したい処理
          attendance = Attendance.find(id)
          if attendance[:started_at].present? && attendance[:finished_at].present? && (item[:started_at].blank? || item[:finished_at].blank?)
            flash[:danger] = "勤務履歴のある日の出退社時間の削除はできません。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif attendance[:started_at].nil? && attendance[:finished_at].nil? && (item[:started_at].present? || item[:finished_at].present?)
            flash[:danger] = "勤務履歴のない日に修正入力はできません。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          attendance.update_attributes!(item)
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else # 勤怠編集に通して良いレコードの絞り込みで、弾かれた者への処理 ⇨attendances_helper
        flash[:danger] = "無効な更新をキャンセルしました。" 
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによる例外処理の分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。" # 例外が発生した時の処理
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  private
  
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
    
    

end
