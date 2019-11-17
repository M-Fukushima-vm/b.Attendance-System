module ApplicationHelper
  
  # ブラウザページタブ　表示情報をページごとに返す
  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end
end
