-- THE GOAL OF THIS PROJECT WAS TO TRY TO RE-CREATE YOUTUBE FROM SCRATCH 
-- FIRST I IDENTIFIED THE PLATFORM'S ENTITIES AND THEIR ATTRIBUTES
-- THEN I DREW A DIAGRAM THAT ILLUSTRATED THE RELATIONSHIPS BETWEEN THE ENTITIES (DIAGRAM CAN BE FOUND UNDER ISSUES AS "YouTube Clone - ER Model")
-- THEN I CREATED A TABLE FOR EACH ENTITY, MAKING SURE I SPECIFIED THE RIGHT DATA TYPE FOR EACH OF THEIR ATTRIBUTES.
--... I ALSO LINKED THE RELATED TABLES USING FOREIGN KEYS (THIS STEP IS SHOWN BELOW)
-- THEN I ADDED DATA INTO THE TABLES. THIS CAN BE DONE MANUALLY AS WELL
-- FINALLY, I WROTE QUERIES TO EXTRACT INSIGHTFUL DATA WHICH CAN BE FURTHER ANALYZED (COULD BE VISUALLY THROUGH TOOLS SUCH AS TABLEAU)...
--...I HAVE INLCUDED SOME OF THESE QUERIES BELOW


-- TABLE CREATION


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
  );
  
  
  
  
  
-- IMPORTANT QUESTIONS AND THE QUERIES THAT ANSWER SUCH QUESTIONS 
  
  
--#1.Who is the user with most subscribers, what is his channel, and how many subscribers does he have? 
SELECT first_name, last_name, name, subscribers FROM channel AS c
INNER JOIN platform_user AS p ON c.user_id = p.platform_user_id
ORDER BY subscribers DESC
LIMIT 1;



--#2.What channel has the most videos? How many videos?
SELECT name, (SELECT COUNT(*) FROM video WHERE channel.channel_id = video.channel_id) AS number_of_videos
FROM channel
ORDER BY number_of_videos DESC
LIMIT 1;

--#3.What was the first channel created and what is its type? When was the channel created and whom does it belong to? 
SELECT name, type, joined, first_name, last_name 
FROM channel
INNER JOIN platform_user ON user_id = platform_user_id 
ORDER BY joined
LIMIT 1;

--#4.What was the first video uploaded and what is its duration? When was it uploaded to the platform? What is the video format and size? 
SELECT title, duration, date, video_format, file_size 
FROM video 
ORDER BY date
LIMIT 1; 

--#5.What is the video with most likes and when was it uploaded to the platform? How many likes?
SELECT title, date, likes FROM video
ORDER BY likes DESC
LIMIT 1;


--#6.What is the video with most dislikes? In addition to the video’s title and number of dislikes, show me the channel it belongs to and the channel’s owner. 
SELECT title, dislikes, name, first_name, last_name FROM video
INNER JOIN channel AS c USING (channel_id) INNER JOIN platform_user AS p ON c.user_id = p.platform_user_id
ORDER BY dislikes DESC
LIMIT 1;


--#7.What is the video with most comments and what channel does it belong to?
SELECT title, (SELECT COUNT(*) FROM comment WHERE video.video_id = comment.video_id) as number_of_comments, name
FROM video
INNER JOIN channel USING (channel_id)
ORDER BY number_of_comments DESC 
LIMIT 1;


--#8.What marketer has most ads on the platform? How many ads?
SELECT marketer_id, m.name, count (ad_id) AS count_ad
FROM ad
JOIN marketer AS m
USING (marketer_id)
GROUP BY marketer_id, m.name
ORDER BY count_ad desc
LIMIT 1;


--#9.Which ad has the most views on the platform and whom does it belong to? 
SELECT ad_id, views, m.name
FROM ad
JOIN marketer AS m
USING (marketer_id)
GROUP BY m.name, ad_id
ORDER BY views desc
limit 1;


--#10.What is the most popular type of ad? 
SELECT type, count (type) AS type_count
FROM ad
GROUP BY type
ORDER BY type_count desc
LIMIT 1;


--#11.How many videos were uploaded in 2020 whose titles include “coronavirus”? 
SELECT COUNT(Title)
FROM Video
WHERE Title LIKE '%coronavirus%' AND date BETWEEN '01-01-2020' AND '12-31-2020';


--#12.Which user has written the most comments? 
SELECT first_name, last_name, (SELECT COUNT(*) FROM comment WHERE platform_user.platform_user_id = comment.user_id) AS number_of_comments
FROM platform_user
ORDER BY number_of_comments DESC
LIMIT 1;


--#13.What is the longest ad on the platform and whom does it belong to? 
SELECT
name AS owner,
Ad_ID,
MAX(Duration) AS Duration
FROM Ad
INNER JOIN Marketer
USING (Marketer_ID)
GROUP BY name, Ad_ID
ORDER BY Duration DESC
LIMIT 1;


--#14.What is the genre of the most watched video on the platform?
SELECT
Genre,
MAX(Views) as Views
FROM Video
GROUP BY Genre
ORDER BY Genre DESC
LIMIT 1;


--#15.What is the genre of the least watched video on the platform?
SELECT
Genre,
MIN(Views) as Views
FROM Video
GROUP BY Genre
ORDER BY Genre ASC
LIMIT 1;


--#16.How many channels were created in 2019?
SELECT COUNT (Channel_ID) FROM channel 
WHERE joined BETWEEN '2019-01-01' and '2019-12-31';


--#17.How many channels were created in 2020? 
SELECT COUNT (Channel_ID) FROM channel 
WHERE joined BETWEEN '2020-01-01' AND '2020-12-31';


--#18.Which videos were posted in March of 2020? Return all of the relevant information. Who uploaded them? 
SELECT title, date, description, duration, views, likes, dislikes, genre, name from video 
INNER JOIN channel
USING (Channel_ID)
WHERE video.date BETWEEN '2020-03-01' AND '2020-03-31';
 

--#19.How many videos last more than an hour? 
SELECT COUNT(duration) FROM video
WHERE duration > 60;


--#20.What is the longest video on the platform? What is its genre? What channel does it belong to? And how many views does it have?
SELECT title, genre, views, name, duration from video
INNER JOIN channel 
USING (Channel_ID)
GROUP BY title, genre, views,name,duration
ORDER BY duration desc
limit 1;


--#21.How many channels have a location other than the United States? 
SELECT COUNT(location) FROM channel
WHERE location NOT LIKE 'United States'; 


--#22. Which comment is the most liked?
SELECT
Comment_ID,
MAX(Likes) as Likes
FROM Comment
GROUP BY Comment_ID
ORDER BY Likes DESC
LIMIT 1;
 

--#23. Which comment has the most replies?
SELECT
Comment_ID,
MAX(Replies) as Replies
FROM Comment
GROUP BY Comment_ID
ORDER BY Replies DESC
LIMIT 1;
 

--#24. Which comment has the most dislikes?
SELECT
Comment_ID,
MAX(Dislikes) as Dislikes
FROM Comment
GROUP BY Comment_ID
ORDER BY Dislikes DESC
LIMIT 1;

  
  
