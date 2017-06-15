require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize (name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.db
    DB[:conn]
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT)
        SQL
    db.execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE students
      SQL
    db.execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
     SQL
    self.class.db.execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
          INSERT INTO students (name, grade) VALUES (?,?)
          SQL
          self.class.db.execute(sql, self.name, self.grade)
          @id = self.class.db.execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create (name, grade)
    self.new(name, grade).save
  end

  def self.new_from_db (attributes)
    self.new(attributes[1], attributes[2], attributes[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM students WHERE name = ?
      SQL
    new_from_db(db.execute(sql, name).first)
  end

end
