require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :id, :title, :body, :associated_author

  def self.find_by_id(id)
  data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
     id = ?
    SQL

    Question.new(data[0])
  end

  def self.find_by_associated_author(id)
  data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
     associated_author = ?
    SQL

    Question.new(data[0])
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @associated_author = options['associated_author']
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT *
      FROM users
      WHERE id = @associated_author
    SQL
    User.new(data[0])
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
end

class Reply
  attr_accessor :id, :question_reference, :reply_reference, :user_reply, :body

  def self.find_by_id(id)
  data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
     id = ?
    SQL

    Reply.new(data[0])
  end

  def self.find_by_user_reply(id)
  data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
     user_reply = ?
    SQL

    Reply.new(data[0])
  end

  def self.find_by_question_id(question_id)
  data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
     question_reference = ?
    SQL
    data.map { |datum| Reply.new(datum)}
  end


  def initialize(options)
    @id = options['id']
    @question_reference = options['question_reference']
    @reply_reference = options['reply_reference']
    @user_reply = options['user_reply']
    @body = options['body']
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @user_reply)
    SELECT *
    FROM users
    WHERE id = ?
    SQL
  end

  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, @question_reference)
    SELECT *
    FROM questions
    WHERE id = ?
    SQL
  end

  def parent_reply
    data = QuestionsDatabase.instance.execute(<<-SQL, @reply_reference)
    SELECT *
    FROM replies
    WHERE id = ?
    SQL
  end

  def child_reply
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT *
    FROM replies
    WHERE reply_reference = @id
    SQL
  end

end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id) #borken
  data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
     id = ?
    SQL

    User.new(data[0])
  end

  def self.find_by_name(fname, lname)
  data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
     fname = ? AND
     lname = ?

    SQL

    User.new(data[0])
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
   Question.find_by_associated_author(@id)
  end

  def authored_replies
    Reply.find_by_user_reply(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

end

class QuestionFollow

  attr_accessor :id, :question_follower, :question

  def self.followers_for_question_id(question)
  data = QuestionsDatabase.instance.execute(<<-SQL, question)
    SELECT *
    FROM question_follows
    JOIN users
      ON question_follower = users.id
    WHERE question = ?
    SQL
    data.map {| datum | User.new(datum)}
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT *
    FROM question_follows
    JOIN questions
    ON question = questions.id
    WHERE question_follower = ?
    SQL
    data.map {| datum | Question.new(datum)}
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT *
    FROM question_follows
    JOIN questions
      ON question = questions.id
    GROUP BY question
    ORDER BY COUNT(question_follower)
       DESC
    LIMIT ?
    SQL
    data.map {| datum | Question.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @question_follower = options['question_follower']
    @question = options['question']
  end
end

class QuestionLike
  attr_accessor :id, :likers, :liked_question

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT *
    FROM question_likes
    JOIN users
      ON likers = users.id
      WHERE liked_question = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT *
    FROM question_likes
    WHERE liked_question = ?

    SQL
    data.length
  end

  def initialize(options)
    @id = options['id']
    @likers = options['likers']
    @liked_question = options['liked_question']
  end
end
