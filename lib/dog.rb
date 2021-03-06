class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  def save
    if self.id then
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  def self.create(name:, breed:)
    new_dog = self.new(name:name, breed:breed)
    new_dog.save
    new_dog
  end
  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
  end
def self.find_by_name(name)
  result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
  new_from_db(result)
end
def self.find_by_id(id)
  result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
  new_from_db(result)
end
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name, breed)
    if dog.empty? then
      dog = self.create(name: name, breed: breed)  #create the object and save it
    else
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    end
    dog
  end
end
