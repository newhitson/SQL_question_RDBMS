CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  associated_author INTEGER NOT NULL,
  FOREIGN KEY (associated_author) REFERENCES user(id)
);

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  question_follower INTEGER NOT NULL,
  question INTEGER NOT NULL,

  FOREIGN KEY (question_follower) REFERENCES user(id),
  FOREIGN KEY (question) REFERENCES questions(id)

);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_reference INTEGER NOT NULL,
  reply_reference INTEGER,
  user_reply INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (reply_reference) REFERENCES replies(id),
  FOREIGN KEY (question_reference) REFERENCES questions(id),
  FOREIGN KEY (user_reply) REFERENCES questions(associated_author)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  likers INTEGER NOT NULL,
  liked_question INTEGER NOT NULL,

  FOREIGN KEY (likers) REFERENCES users(id),
  FOREIGN KEY (liked_question) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Mary', 'Howell'),
  ('Nick', 'Whitson'),
  ('Kelly', 'Chung');

  INSERT INTO
    questions (title, body, associated_author)
  VALUES
    ('something', 'my monitor is broken',(SELECT id FROM users WHERE fname = 'Mary')),
    ('else', 'My washing machine dosent work', (SELECT id FROM users WHERE fname = 'Nick'));

  INSERT INTO
    replies (question_reference, reply_reference, user_reply, body)
  VALUES
    ((SELECT id FROM questions WHERE title = 'something'), NULL,(SELECT id FROM users WHERE fname = 'Nick'), 'this is a reply'),
    ((SELECT id FROM questions WHERE title = 'something'), 1,(SELECT id FROM users WHERE fname = 'Kelly'), 'did you restart it?');


    INSERT INTO
      question_likes (likers, liked_question)
    VALUES
      (1,2),
      (2,1);

    INSERT INTO
      question_follows(question_follower, question)
    VALUES
      (3,1),
      (2,2),
      (1,1),
      (2,1);
