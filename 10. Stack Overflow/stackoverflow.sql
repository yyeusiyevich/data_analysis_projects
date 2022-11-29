--- 1. Find the number of questions that have scored over 300 points or at least 100 times 
---    have been added to the "Bookmarks".
SELECT COUNT(*)
FROM   stackoverflow.posts
WHERE  (score > 300
          OR favorites_count >= 100)
       AND post_type_id = 1; 

--- 2. How many questions were asked daily from November 1 to 18, 2008 inclusively? 
---    Round the result to integer.
SELECT ROUND(AVG(counted))
FROM   (SELECT COUNT(*) AS counted,
               creation_date :: DATE
        FROM   stackoverflow.posts
        WHERE  post_type_id = 1
               AND creation_date BETWEEN '2008-11-01' AND '2008-11-19'
        GROUP  BY 2
        ORDER  BY 2) cnt; 

--- 3. How many users received a badge on sign-up day? Print out the number of unique users.
SELECT COUNT(DISTINCT user_id)
FROM   stackoverflow.badges
       JOIN stackoverflow.users
         ON badges.user_id = users.id
WHERE  users.creation_date :: DATE = badges.creation_date :: DATE; 

--- 4. How many Joel's Coehoorn unique posts received at least one vote?
SELECT COUNT(DISTINCT posts.id)
FROM   stackoverflow.users
       JOIN stackoverflow.posts
         ON users.id = posts.user_id
       JOIN stackoverflow.votes
         ON votes.post_id = posts.id
WHERE  users.display_name = 'Joel Coehoorn'; 

--- 5. Upload all columns of the `vote_types` table. Add a `rank` column to the table that will include 
---    the record numbers in reverse order. The table should be sorted by `id` column.
SELECT *,
       ROW_NUMBER()
         OVER(
           ORDER BY id DESC) AS rank
FROM   stackoverflow.vote_types
ORDER  BY id; 

--- 6. Select 10 users who gave the most `Close` votes. Display a table with two columns: user ID and number of votes. 
---    Sort the data first by decreasing votes number, then by decreasing user ID.
SELECT user_id,
       COUNT(votes.id) AS cnt
FROM   stackoverflow.votes
       JOIN stackoverflow.vote_types
         ON votes.vote_type_id = vote_types.id
WHERE  vote_types.name = 'Close'
GROUP  BY user_id
ORDER  BY 2 DESC
LIMIT  10; 

--- 7. Select 10 users based on the number of bagdes received between November 15 and December 15, 2008 inclusive. 
---    Display next columns:
---             - user ID
---             - number of badges;
---             - place in the ranking - the more badges, the higher the rating.
---    For users who have the same number of badges, assign the same rank. Sort the rows by the number of badges 
---    in descending order, and then by user ID in ascending order.
SELECT   *,
         DENSE_RANK() OVER(ORDER BY cnt DESC)
FROM     (
                  SELECT   user_id,
                           count(id) AS cnt
                  FROM     stackoverflow.badges
                  WHERE    badges.CREATION_DATE::DATE BETWEEN '2008-11-15' AND '2008-12-15'
                  GROUP BY user_id
                  ORDER BY cnt DESC
                  LIMIT    10) tempo;

--- 8. How many points does each post get on average? Form a table with the following columns:
---       - post title;
---       - user ID;
---       - number of points;
--- The average number of points per post round to integer. Ignore untitled posts, as well as those with zero points.
SELECT title,
       user_id,
       score,
       ROUND(AVG(score)
               OVER(
                 PARTITION BY user_id)) AS calculated
FROM   stackoverflow.posts
WHERE  title IS NOT NULL
       AND score != 0; 
    
--- 9. Display the posts titles that have been written by users who have received over 1,000 badges. 
---    Untitled publications must not be included.
SELECT title
FROM   stackoverflow.posts
WHERE  title IS NOT NULL
       AND user_id IN (SELECT user_id
                       FROM   stackoverflow.badges
                       GROUP  BY user_id
                       HAVING COUNT(name) > 1000); 

--- 10. Write a query that displays user data from Canada. Divide users into three groups depending on the number of profile views:
---     - 350 views and more - group 1;
---     - below 350 but above or equal to 100 - group 2;
---     - below 100 views - group 3.
---     Display the user ID, the number of profile views, and the group. Users with zero profile views must not be included.
SELECT id,
       views,
       CASE
         WHEN views >= 350 THEN 1
         WHEN views < 100 THEN 3
         ELSE 2
       end
FROM   stackoverflow.users
WHERE  location LIKE '%Canada%'
       AND views != 0;

--- 11. Complete the previous query. Display leaders for each group - users who have reached maximum views in their group. 
---     Print next columns: user ID, group, and number of views. Sort the table by views in descending order and increasing ID value.
SELECT id,
       views,
       statement
FROM   (SELECT statement,
               id,
               views,
               MAX(views)
                 OVER(
                   PARTITION BY statement
                   ORDER BY views DESC)
        FROM   (SELECT id,
                       views,
                       CASE
                         WHEN views >= 350 THEN 1
                         WHEN views < 100 THEN 3
                         ELSE 2
                       END AS statement
                FROM   stackoverflow.users
                WHERE  location LIKE '%Canada%'
                       AND views != 0) t) t2
WHERE  views = max
ORDER  BY views DESC,
          id; 

--- 12. Calculate daily users growth rate in November 2008. Form a table with next columns:
---     - day number;
---     - number of registered users;
---     - cumulative users value.
SELECT *,
       SUM(users_cnt)
         over(
           ORDER BY rn) AS cumsum
FROM   (SELECT DENSE_RANK()
                 over(
                   ORDER BY DATE_TRUNC('day', creation_date)::DATE) AS rn,
               COUNT(id)                                            AS users_cnt
        FROM   (SELECT *
                FROM   stackoverflow.users
                WHERE  creation_date :: DATE BETWEEN
                       '2008-11-01' AND '2008-11-30'
                ORDER  BY creation_date DESC) tempo1
        GROUP  BY DATE_TRUNC('day', creation_date) :: DATE) tempo2; 

--- 13. For each user that has posted at least one post, find the interval between sign-up and the first post. Display:
---     - user ID;
---     - the difference in time between registration and first publication.
SELECT user_id,
       p_creation - a_creation AS diff
FROM   (SELECT user_id,
               users.creation_date               AS a_creation,
               posts.creation_date               AS p_creation,
               ROW_NUMBER()
                 OVER(
                   partition BY user_id
                   ORDER BY posts.creation_date) AS rn
        FROM   stackoverflow.users
               JOIN stackoverflow.posts
                 ON users.id = posts.user_id) t
WHERE  rn = 1; 
      
