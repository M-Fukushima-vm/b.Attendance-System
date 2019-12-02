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
  
  # 勤怠編集に通して良いレコードを絞り込みします
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].present? && item[:finished_at].present? && item[:started_at] < item[:finished_at]
        next
      elsif item[:started_at].present? && item[:finished_at].nil?
        next
      elsif item[:started_at].nil? && item[:finished_at].nil?
        next
      end
    end
    return attendances
  end
  
end
