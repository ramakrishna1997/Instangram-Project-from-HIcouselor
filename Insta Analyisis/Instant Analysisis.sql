CREATE DATABASE insta;
USE insta;
SELECT * FROM comments_cleaned;
SELECT * FROM follows_cleaned;
SELECT * FROM likes_cleaned;
SELECT * FROM photo_tags_cleaned;
SELECT * FROM photos_cleaned;
SELECT * FROM tags_cleaned;
SELECT * FROM users_cleaned;

-- Find the 5 oldest users.
SELECT 
    id, username, created_at
FROM
    users_cleaned
ORDER BY created_at ASC
LIMIT 5;
-- What day of the week do most users register on? 
-- We need to figure out when to schedule an ad campgain
SELECT 
    DATE(created_at) AS day_week, COUNT(*) AS num_of_campgain
FROM
    users_cleaned
GROUP BY day_week
ORDER BY num_of_campgain DESC
LIMIT 1;

-- We want to target our inactive users with an email campaign. Find the users who have never posted a photo.

SELECT 
    username
FROM
    users_cleaned
WHERE
    id NOT IN (
    SELECT DISTINCT user_id
        FROM
            Photos_cleaned);
-- We're running a new contest to see who can get the most likes on a single photo. WHO WON?
 -- username, id, image_url, Total_Likes, 
SELECT * FROM likes_cleaned;
SHOW tables;

SELECT 
    u.username, p.image_url, l.photo_id
FROM
    likes_cleaned l
        JOIN
    photos_cleaned p ON p.user_id = l.user_id
        JOIN
    users_cleaned u ON u.id = p.id
WHERE
    u.username = 'Harrison.Beatty50'
GROUP BY u.username , p.image_url , l.photo_id
ORDER BY l.photo_id DESC
LIMIT 10;

-- Our Investors want to know...How many times does the average user post? (total number of photos/total number of users)

SELECT COUNT(*) AS total_number_of_photos, COUNT(DISTINCT user_id) AS total_number_of_users , total_number_of_photos/total_number_of_users
FROM photos_cleaned;

SELECT COUNT(*) AS total_number_of_photos, COUNT(DISTINCT user_id) AS total_number_of_users, ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2) AS average_posts_per_user
FROM photos_cleaned;

SELECT ROUND((SELECT count(*) FROM photos_cleaned)/(SELECT count(*) FROM users_cleaned),2) AS average_posts_per_user;

SELECT u.username, COUNT(p.image_url) AS num_posts, 
  @rank := @rank + 1 AS rank1
FROM photos_cleaned p
JOIN users_cleaned u ON p.user_id = u.id
CROSS JOIN (SELECT @rank := 0) r
GROUP BY p.user_id,u.username
ORDER BY num_posts DESC
LIMIT 10;

-- Total Posts by users (longer versionof SELECT COUNT(*)FROM photos)

SELECT COUNT(*) FROM photos_cleaned;
-- Total numbers of users who have posted at least one time

SELECT count(distinct user_id) from photos_cleaned;

-- A brand wants to know which hashtags to use in a post. What are the top 5 most commonly used hashtags?

SELECT * FROM comments_cleaned;
SELECT * FROM follows_cleaned;
SELECT * FROM likes_cleaned;
SELECT * FROM photo_tags_cleaned;
SELECT * FROM photos_cleaned;
SELECT * FROM tags_cleaned;
SELECT * FROM users_cleaned

SELECT DISTINCT tag_name ,count(*) as most_commonly FROM  tags_cleaned
GROUP BY tag_name 
order by most_commonly desc
LIMIT 5;


select t.tag_name,count(photo_id) as total from tags_cleaned t 
join photo_tags_cleaned pt on t.id=pt.tag_id
group by t.tag_name
order by total desc;

SELECT tag_name, COUNT(photo_id) AS total
FROM tags_cleaned t
JOIN photo_tags_cleaned pt ON t.id = pt.tag_id
GROUP BY tag_name
ORDER BY total DESC;

-- We have a small problem with bots on our site. Find users who have liked every single photo on the site

SELECT u.username, l.photo_id FROM users_cleaned u
JOIN photos_cleaned c ON c.id=u.id
JOIN likes_cleaned l ON l.user_id=p.user_id;



SELECT l.user_id, u.username
FROM likes_cleaned l
JOIN( SELECT * from photos_cleaned p) as p on l.photo_id =p.id
JOIN users_cleaned u on l.user_id = u.id
GROUP BY l.user_id,u.username,l.photo_id

SELECT l.user_id, u.username
FROM likes_cleaned l
JOIN (
  SELECT count(p.id)
  FROM photos_cleaned p
) AS p ON l.photo_id = p.id
JOIN users_cleaned u ON l.user_id = u.id
GROUP BY l.user_id, u.username
HAVING COUNT(DISTINCT l.photo_id) = (SELECT COUNT(*) FROM photos_cleaned)




SELECT u.id, u.username, COUNT(l.photo_id) AS total_likes_by_user
FROM users_cleaned u
LEFT JOIN photos_cleaned c ON c.user_id=u.id
LEFT JOIN likes_cleaned l ON l.photo_id=c.id
GROUP BY u.id, u.username
ORDER BY total_likes_by_user DESC
LIMIT 5;
-- We also have a problem with celebrities. Find users who have never commented on a photo

SELECT u.username,c.comment_text from users_cleaned u
LEFT JOIN comments_cleaned c ON u.id=c.user_id
where c.comment_text IS NULL;

-- Are we overrun with bots and celebrity accounts? Find the percentage of our users who have either never commented on a photo or have commented on every photo

SELECT tableA.total_A AS 'Number Of Users who never commented',
(tableA.total_A/(SELECT COUNT(*) FROM users))*100 AS '%',
tableB.total_B AS 'Number of Users who commented on photos',
(tableB.total_B/(SELECT COUNT(*) FROM users))*100 AS '%'
FROM
(
SELECT COUNT(*) AS total_A FROM
(SELECT username,comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NULL) AS total_number_of_users_without_comments
) AS tableA
JOIN
(
SELECT COUNT(*) AS total_B FROM
(SELECT username,comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NOT NULL) AS total_number_users_with_comments
)AS users u








