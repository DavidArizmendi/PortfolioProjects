-- THE GOAL OF THIS PROJECT WAS TO TRY TO RE-CREATE YOUTUBE FROM SCRATCH 
-- FIRST I IDENTIFIED THE PLATFORM'S ENTITIES AND THEIR ATTRIBUTES
-- THEN I DREW A DIAGRAM THAT ILLUSTRATED THE RELATIONSHIPS BETWEEN THE ENTITIES 



CREATE TABLE platform_user (
  Platform_User_ID SERIAL PRIMARY KEY, 
  First_Name VARCHAR(30) NOT NULL,
  Last_Name VARCHAR(30) NOT NULL,
  Email VARCHAR(30) NOT NULL UNIQUE,               
  Phone_Number VARCHAR(15) NOT NULL UNIQUE,
  Gender VARCHAR(20),
  Platform_User_Subscriber_ID INT
);

ALTER TABLE platform_User ADD CONSTRAINT Platform_User_Subscriber_ID_fk FOREIGN KEY (Platform_User_Subscriber_ID) references platform_user(Platform_User_ID);

CREATE TABLE Channel (
  Channel_ID SERIAL PRIMARY KEY, 
  Name VARCHAR(100) NOT NULL UNIQUE,
  Subscribers INT NOT NULL,
  Location VARCHAR(100) NOT NULL, 
  Joined DATE NOT NULL, 
  Type VARCHAR(50) NOT NULL,
  User_ID INT, 
  CONSTRAINT Channel_User_fkey
    FOREIGN KEY (User_ID) REFERENCES platform_user (Platform_User_ID)
);

CREATE TABLE Video (
  Video_ID SERIAL PRIMARY KEY, 
  Title VARCHAR(100) NOT NULL,
  Date DATE NOT NULL,
  Description VARCHAR(100), 
  Duration DEC(4,1) NOT NULL, 
  Views INT NOT NULL NOT NULL,
  Likes INT NOT NULL,
  Dislikes INT NOT NULL,
  Genre VARCHAR(100) NOT NULL,
  File_Size DECIMAL(4,1) NOT NULL CHECK (File_Size < 128),
  Video_Format VARCHAR(100) NOT NULL,
  Channel_ID INT, 
  CONSTRAINT Video_Channel_fkey
    FOREIGN KEY (Channel_ID) REFERENCES Channel (Channel_ID)
);

CREATE TABLE Comment (
  Comment_ID SERIAL PRIMARY KEY, 
  Replies INT NOT NULL,
  Likes INT NOT NULL,
  Dislikes INT NOT NULL,
  Pinned BOOLEAN NOT NULL,
  Mentions INT NOT NULL,
  User_ID INT,
  Video_ID INT, 
  CONSTRAINT Comment_User_fkey
    FOREIGN KEY (User_ID) REFERENCES platform_user (Platform_User_ID),
  CONSTRAINT Comment_Video_fkey
    FOREIGN KEY (Video_ID) REFERENCES Video (Video_ID)
);

CREATE TABLE Marketer (
  Marketer_ID SERIAL PRIMARY KEY, 
  Name VARCHAR(30) NOT NULL UNIQUE,
  Type VARCHAR(100) NOT NULL,
  Website VARCHAR(50) UNIQUE
);

CREATE TABLE Ad (
  Ad_ID SERIAL PRIMARY KEY, 
  Type VARCHAR(100) NOT NULL,
  Duration INT NOT NULL, 
  Views INT NOT NULL,
  Payment_Per_View DEC(4,2) NOT NULL,
  Marketer_ID INT, 
  CONSTRAINT Ad_Marketer_fkey
    FOREIGN KEY (Marketer_ID) REFERENCES Marketer (Marketer_ID)
);


CREATE TABLE User_Video(
User_ID SERIAL,
Video_ID SERIAL,
PRIMARY KEY (User_ID, Video_ID),
CONSTRAINT Platform_User_fk FOREIGN KEY (User_ID) REFERENCES platform_user (Platform_User_ID),
  CONSTRAINT Video_fk FOREIGN KEY (Video_ID) REFERENCES Video (Video_ID)
  );

CREATE TABLE Video_Ad ( 
  Video_ID SERIAL,
  Ad_ID SERIAL,
  PRIMARY KEY (Video_ID, Ad_ID ),
  CONSTRAINT Video_fk FOREIGN KEY (Video_ID) REFERENCES Video (Video_ID),
  CONSTRAINT Ad_fk FOREIGN KEY (Ad_ID) REFERENCES Ad (Ad_ID)
