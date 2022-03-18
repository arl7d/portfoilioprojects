
  SELECT *
  FROM [ramen].[dbo].[ramen_ratings]

  /* average stars per brand */

  SELECT Brand, AVG(Stars) as ave_stars
  FROM [ramen].[dbo].[ramen_ratings]
  GROUP BY Brand
  ORDER  BY ave_stars DESC

  /* looks like there are many brands where they
  only had few entries on this list */

  /* top brands with more than 20 entries */

  SELECT Brand, Country, count(Brand) as count, ROUND(AVG(Stars),2) as ave_stars
  FROM ramen.dbo.ramen_ratings
  GROUP BY Brand, Country
  HAVING count(Brand) > 20
  ORDER BY ave_stars DESC

  /* top countries with more than 20 entries */

  SELECT Country ,count(Country) as count, ROUND(AVG(Stars),2) as ave_stars
  FROM ramen.dbo.ramen_ratings
  GROUP BY Country
  HAVING count(Country) > 20
  ORDER BY ave_stars DESC

  /* top chicken ramen */

  SELECT Brand, Variety, Stars
  FROM ramen.dbo.ramen_ratings
  WHERE Variety LIKE '%chicken%'
  ORDER BY Stars DESC

  /* which brand has highest average rating chicken ramen with more than 5 entries*/

  WITH chicken AS
  (SELECT Brand, Variety, Stars
  FROM ramen.dbo.ramen_ratings
  WHERE Variety LIKE '%chicken%')

  SELECT Brand, count(Brand) as entries, ROUND(AVG(Stars),2) as ave_stars
  FROM chicken
  GROUP BY Brand
  HAVING count(Brand) > 5
  ORDER BY ave_stars DESC

  /* check lucky me! entries (because this is a Filipino brand, and i am Filipino.. lol) */

  SELECT *
  FROM ramen.dbo.ramen_ratings
  WHERE Brand LIKE '%Lucky Me%'
  ORDER BY Stars DESC

  /* Check counts per style */

  SELECT Style, count(Style) as count
  FROM ramen.dbo.ramen_ratings
  GROUP BY Style
  ORDER BY count DESC

 /* top spicy ramen */

  SELECT Brand, Variety, Stars
  FROM ramen.dbo.ramen_ratings
  WHERE Variety LIKE '%spicy%'
  ORDER BY Stars DESC

 /* which brand has highest average rating spicy or hot ramen with more than 5 entries*/

  WITH spicy AS
  (SELECT Brand, Variety, Stars
  FROM ramen.dbo.ramen_ratings
  WHERE Variety LIKE '%spicy%' OR Variety LIKE '%hot%')

  SELECT Brand, count(Brand) as entries, ROUND(AVG(Stars),2) as ave_stars
  FROM spicy
  GROUP BY Brand
  HAVING count(Brand) > 5
  ORDER BY ave_stars DESC
