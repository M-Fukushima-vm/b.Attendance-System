module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  # 勤怠編集に許可する処理を定義
  def attendances_update_valid?
    attendances_params.each do |id, item| # データベースの操作を保障したい処理
    attendance = Attendance.find(id)

    # スキップする条件を next
    
      # 【勤務履歴の捏造不可】
      if attendance[:started_at].blank? && attendance[:finished_at].blank? && (item[:started_at].present? || item[:finished_at].present?)
        # flash[:danger] = "勤務履歴のない日に修正入力はできません。"
        next
        # redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
      
      # 【勤務履歴の抹消不可】
      elsif attendance[:started_at].present? && attendance[:finished_at].present? && (item[:started_at].blank? || item[:finished_at].blank?)
        # flash[:danger] = "勤務履歴のある日の出退社時間の削除はできません。"
        next
        # redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        
      # 【出勤履歴の抹消不可】
      elsif attendance[:started_at].present? && attendance[:finished_at].blank? && item[:started_at].blank?
        # flash[:danger] = "勤務履歴の削除はできません。"
        next
        # redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        
      end
    # 上記スキップ条件に引っかからなかったレコードのみ更新
        attendance.update_attributes!(item)
    end
  end
  
  
  
end
