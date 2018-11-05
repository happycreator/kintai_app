class Form::AttendanceCollection < Form::Base
  DEFAULT_ITEM_COUNT = 31
  attr_accessor :attendances

  def initialize(attributes = {}, current_user = nil)
    @current_user = current_user
    super attributes
    # 月初めのデータを生成して変数に格納
    first_date_of_month = DateTime.current.beginning_of_month
    # 月末のデータを生成して変数に格納
    last_date_of_month = DateTime.current.end_of_month
    # 月初めのデータから月末までのデータのループ処理
    attendances_array = []
    (first_date_of_month...last_date_of_month).each do |date|
      # 配列に順次格納していく
      attendances_array << Form::Attendance.new({arriving_at: date, leaving_at: date})
    end

    self.attendances = attendances_array
    #self.attendances = DEFAULT_ITEM_COUNT.times.map { Form::Attendance.new({arriving_at: Time.now, leaving_at: Time.now}) } unless attendances.present?
  end

  def attendances_attributes=(attributes)
    self.attendances = attributes.map do |_, attendance_attributes|
      Form::Attendance.new(attendance_attributes)
    end
  end

  def valid?
    valid_attendances = target_attendances.map(&:valid?).all?
    super && valid_attendances
  end

  def save
    return false unless valid?
    Attendance.transaction { target_attendances.each(&:save!) }
    true
  end

  def target_attendances
    self.attendances.select { |v| v.user_id = @current_user.id }
  end
end