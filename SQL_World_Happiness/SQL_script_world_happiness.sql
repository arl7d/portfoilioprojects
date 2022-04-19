/* Below is an SQL script to combine world happiness scores from individual tables of yearly data
into one big table that would contain the data from 2015 to 2021

There were some cleaning & feature engineering that had to be done prior the union

Then some EDA was done on the combined data
*/

  /* change column names for commonality */

  EXEC sp_rename 'dbo.2018_happiness.Freedom_to_make_life_choices', 'Freedom', 'COLUMN';

  EXEC sp_rename 'dbo.2019_happiness.Country_or_region', 'Country', 'COLUMN';

  EXEC sp_rename '[dbo].[2020_happiness].[Country_name]', '[Country]', 'COLUMN';

  EXEC sp_rename 'dbo.2019_happiness.Perceptions_of_corruption', 'Trust_Government_Corruption', 'COLUMN';

  /* add year to table */

  ALTER TABLE [world_happiness].[dbo].[2021_happiness]
  ADD Rank smallint;

  /* insert year data into  year column */

  UPDATE [world_happiness].[dbo].[2021_happiness]
  SET Year = 2021

  /* 2020 & 2021 tables do not have "Rank" columns, so we'll add it to them" */

  SELECT *
  FROM [world_happiness].[dbo].[2020_happiness]

  ALTER TABLE [world_happiness].[dbo].[2020_happiness]
  ADD Rank smallint;

	UPDATE C1
	SET C1.Rank = C2.Rank
	FROM [world_happiness].[dbo].[2020_happiness] C1
	JOIN (SELECT 
		DENSE_RANK() OVER (ORDER BY Ladder_score DESC) AS 'Rank', Country
	FROM [world_happiness].[dbo].[2020_happiness]) C2
	ON C1.Country = C2.Country

  SELECT *
  FROM [world_happiness].[dbo].[2021_happiness]

  ALTER TABLE [world_happiness].[dbo].[2021_happiness]
  ADD Rank smallint;

	UPDATE C1
	SET C1.Rank = C2.Rank
	FROM [world_happiness].[dbo].[2021_happiness] C1
	JOIN (SELECT 
		DENSE_RANK() OVER (ORDER BY Ladder_score DESC) AS 'Rank', Country
	FROM [world_happiness].[dbo].[2021_happiness]) C2
	ON C1.Country = C2.Country


/* unionize everything with columns that are present on all tables then create a new table with all these data */

SELECT *
	INTO [world_happiness].[dbo].[2015_to_2021_happiness]
FROM 
(
	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Health_Life_Expectancy]
		  ,[Freedom]
		  ,[Trust_Government_Corruption]
		  ,[Generosity]
	  FROM [world_happiness].[dbo].[2015_happiness]

	  UNION

	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Happiness_Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Health_Life_Expectancy]
		  ,[Freedom]
		  ,[Trust_Government_Corruption]
		  ,[Generosity]
	  FROM [world_happiness].[dbo].[2016_happiness]

	  UNION

	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Happiness_Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Health_Life_Expectancy]
		  ,[Freedom]
		  ,[Trust_Government_Corruption]
		  ,[Generosity]
	  FROM [world_happiness].[dbo].[2017_happiness]

	  UNION

	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Healthy_life_expectancy]
		  ,[Freedom]
		  ,[Generosity]
		  ,[Trust_Government_Corruption]
	  FROM [world_happiness].[dbo].[2018_happiness]

	  UNION

	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Healthy_life_expectancy]
		  ,[Freedom]
		  ,[Generosity]
		  ,[Trust_Government_Corruption]
	  FROM [world_happiness].[dbo].[2019_happiness]

	  UNION

	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Healthy_life_expectancy]
		  ,[Freedom]
		  ,[Generosity]
		  ,[Trust_Government_Corruption]
	  FROM [world_happiness].[dbo].[2020_happiness]

	  UNION

	  SELECT TOP (1000) [Country]
		  ,[Year]
		  ,[Rank]
		  ,[Score]
		  ,[Economy_GDP_per_Capita]
		  ,[Healthy_life_expectancy]
		  ,[Freedom]
		  ,[Generosity]
		  ,[Trust_Government_Corruption]
	  FROM [world_happiness].[dbo].[2021_happiness]
) a


/* unfortunately, scoring formats of some features were changed starting 2020, 
thus, we can't use the combined data of these columns to plot trends. 
Nonetheless, we can still see the trend in happiness rank & scores*/


SELECT TOP (1000) [Country]
      ,[Year]
      ,[Rank]
      ,[Happiness_Score]
  FROM [world_happiness].[dbo].[2015_to_2021_happiness]

/* check average rank & score for each country */

  SELECT Country, AVG(Rank) ave_rank, AVG(Happiness_Score) ave_score
  FROM [world_happiness].[dbo].[2015_to_2021_happiness]
  GROUP BY Country
  ORDER BY ave_score DESC

  /* see the difference between 2015 & 2021 rank & scores*/

  SELECT Country, Year, Rank, Happiness_Score
  FROM [world_happiness].[dbo].[2015_to_2021_happiness]
  WHERE Year = 2015 OR Year = 2021

  /* check which countries improved the most & vice versa in terms of happiness score */

  SELECT a.Country, a.Score as '2015_Score', b.Score as '2021_Score', b.Score - a.Score as 'Score_Delta'
  FROM [world_happiness].[dbo].[2015_happiness] a
  INNER JOIN [world_happiness].[dbo].[2021_happiness] b ON a.Country = b.Country
  ORDER BY Score_Delta DESC

  /* check which countries improved the most & vice versa in terms of ranking */

  SELECT a.Country, a.Rank as '2015_Rank', b.Rank as '2021_Rank', b.Rank - a.Rank as 'Rank_Delta'
  FROM [world_happiness].[dbo].[2015_happiness] a
  INNER JOIN [world_happiness].[dbo].[2021_happiness] b ON a.Country = b.Country
  ORDER BY Rank_Delta DESC
  
  /*
  Major Findings:
	1. Venezuela is the country that degraded the most (in terms of people's happiness). They ranked #23 in 2015, but in 2021, they are now rank #105
	2. Ivory Coast (a country in West Africa), is the one that improved the most, from Rank #151 in 2015, to #83 in 2021 
  */
