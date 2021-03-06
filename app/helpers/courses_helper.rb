require 'set'

module CoursesHelper
  def week_data_to_num(week_data)
    param = {
        '周一' => 0,
        '周二' => 1,
        '周三' => 2,
        '周四' => 3,
        '周五' => 4,
        '周六' => 5,
        '周天' => 6,
    }
    param[week_data] + 1
  end

  # 生成11行7列的数据
  def get_current_curriculum_table(courses,user)
    # course_time = Array.new(11) { Array.new(7, '') }
    course_time = Array.new(11) {Array.new(7) {Array.new(3, '')}}
    courses.each do |cur|
      real_course_name = cur.name
      @grades = cur.grades
      # check whether the course is open.
      @grades.each do |grade|
        if grade.user.name == user.name
          if grade.open == true
            # if it is open, append "_open" to the course name.
           real_course_name = real_course_name.concat("_open")
          end
        end
      end
      cur_time = String(cur.course_time)
      cur_id = cur.course_time
      end_j = cur_time.index('(')
      j = week_data_to_num(cur_time[0...end_j])
      t = cur_time[end_j + 1...cur_time.index(')')].split("-")
      for i in (t[0].to_i..t[1].to_i).each
        course_time[(i-1)*7/7][j-1][0] = real_course_name
        course_time[(i-1)*7/7][j-1][1] = cur.course_week
        course_time[(i-1)*7/7][j-1][2] = cur.class_room
      end
    end
    course_time
  end

  def get_course_score_table(courses, user)
    # 二维数组,表示学分
    score_table = Array.new(2) { Array.new(3, 0.0) }

    # 遍历用户已经选的课
    courses.each do |cur|
      f_credit = cur.credit.split('/')[1].to_f
      # 课程学分按照类别进行分别计算
      if cur.course_type == '公共选修课'
        score_table[0][0] += f_credit
        if is_end_course(cur, user)
          score_table[1][0] += f_credit
          score_table[1][2] += f_credit
        end  
      elsif cur.course_type == '公共必修课'
        if is_end_course(cur, user)
          score_table[1][2] += f_credit
        end  
      elsif cur.course_type.include?'专业' or cur.course_type.include?'一级学科'
        score_table[0][1] += f_credit
        if is_end_course(cur, user)
          score_table[1][1] += f_credit
          score_table[1][2] += f_credit
        end
      end
      score_table[0][2] += f_credit
    end
    score_table
  end

  def is_end_course(course, user)
    @grades = course.grades
    @is_end = false
    @grades.each do |grade|
      if grade.user.name == user.name and grade.grade != nil and grade.grade != '' and grade.grade >= 60
        @is_end = true
      end
    end
    return @is_end
  end

  def is_open_course(course, user)
    @grades=course.grades
    @is_open = false
    @grades.each do |grade|
      if grade.user.name == user.name
         if grade.open == true
          @is_open = true
         end
      end
    end
    return @is_open
  end

  def date_transform(date)
    if date.include?"周一"
     return '1'
    elsif date.include?"周二"
     return '2'
    elsif date.include?"周三"
     return '3'
    elsif date.include?"周四"
     return '4'
    elsif date.include?"周五"
     return '5'
    elsif date.include?"周六"
     return '6'
    elsif date.include?"周天"
     return '7'
    end 
  end

  def get_course_info(courses, type)
    res = Set.new
    courses.each do |course|
      res.add(course[type])
    end
    res.to_a.sort
  end

  def check_course_condition(course, key, value)
    if key == 'course_time' 
      if value == '' or date_transform(course[key]) == value
        return true
      end
    elsif value == '' or course[key] == value
      return true
    end
    false
  end

  def check_course_keyword(course, key, value)
    if value == '' or value == nil or course[key].include?value
      return true
    end
    false
  end

end