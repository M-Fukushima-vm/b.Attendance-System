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
  
  $error_flash_message = ''
  
  # 勤怠編集に許可する処理(除外する条件)を定義
  def attendances_update_valid?
    attendances_params.each do |id, item| # データベースの操作を保障したい処理
    attendance = Attendance.find(id)

    # スキップする条件を next
    
      # 【勤務履歴の捏造不可】
      if attendance[:started_at].blank? && attendance[:finished_at].blank? && (item[:started_at].present? || item[:finished_at].present?)
        $error_flash_message << "・勤務履歴のない日への出退社時間の入力<br>"
        next
      
      # 【勤務履歴の抹消不可】
      elsif attendance[:started_at].present? && attendance[:finished_at].present? && (item[:started_at].blank? || item[:finished_at].blank?)
        $error_flash_message << "・勤務履歴のある日の出退社時間の削除<br>"
        next

      # 【時間の関係性の逆転した登録不可】
      elsif item[:started_at].present? && item[:finished_at].present? && (item[:started_at] > item[:finished_at])
        $error_flash_message << "・時間の関係性の逆転した登録<br>"
        next
      
      # 【出社履歴の抹消不可】
      elsif attendance[:started_at].present? && item[:started_at].blank?
        $error_flash_message << "・出社履歴の削除<br>"
        next
        
      end
    # 上記スキップ条件に引っかからなかったレコードのみ更新
        attendance.update_attributes!(item)
    end
  end
  
  # update_one_month でのフラッシュ切り替え
  def update_one_month_flash
    if $error_flash_message.present?
      $error_flash_message << "【上記の許可されていない勤怠編集、誤入力の可能性が見つかりました。】<br>"
      flash[:danger] = $error_flash_message
      flash[:info] = "該当しない日にちの編集内容のみ更新しました。"
      $error_flash_message = ''
    elsif
      flash[:success] = "1ヶ月分の勤怠編集内容を更新しました。"
    end
  end
  
end
