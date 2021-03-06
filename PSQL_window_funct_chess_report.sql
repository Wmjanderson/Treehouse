
/* questions
Q1 - How does each player’s ranking compare to the overall field?
Q2 - How many total matches were played at the tournament?
Q3 - Which team had the highest winning percentage?
Q4 - Who is the top-=ranked player on each team?
Q5 - Do higher ranked players win more often than lower ranked ones?
*/

SELECT PLAYER_NAME,
	PLAYER_RANKING,
	PLAYER_TEAM,
	COUNT(MATCH_ID) AS MATCHES_PLAYED,
	SUM(CHECKMATE) AS MATCHES_WON,
	SUM(CHECKMATE)/COUNT(MATCH_ID) AS WIN_RATE,

	— Q1 next two statements using the OVER () keyword
	AVG(PLAYER_RANKING) OVER() AS AVG_RANKING,
	PLAYER_RANKING - AVG(PLAYER_RANKING) OVER () AS DIFF_FROM_AVERAGE,

	— Q2 next statement
	SUM(SUM(CHECKMATE)) OVER () AS TOTAL_MATCHES,
	SUM(MAX(CHECKMATE)) OVER () AS PLAYERS_WITH_WINS,
	MAX(SUM(CHECKMATE)) OVER () AS HIGHEST_WINS,

	— Q3 using OVER (PARTITION BY ..)
	SUM(SUM(CHECKMATE)) OVER (PARTITION BY PLAYER_TEAM)/
	SUM(COUNT(MATCH_ID)) OVER (PARTITION BY PLAYER_TEAM) AS TEAM_WIN_RATE,
	MIN(PLAYER_RANKING) OVER (PARTITION BY SUM(CHECKMATE)) AS TIEBREAKER
	MIN(PLAYER_RANKING) OVER (PARTITION BY SUM(CHECKMATE),PLAYER_TEAM) AS TIEBREAKER_TEAM,

	— Q4 using RANK (PARTITION BY .. ORDER BY .. A/DE.SC) an ordering function
	RANK() OVER (PARTITION BY PLAYER_TEAM ORDER BY PLAYER_RANKING DESC) AS RANKING,

	/* Q5 using Frame clauses OVER (ORDER BY .. ROWS BETWEEN/PRECEDING/FOLLOWING) 
	the FRAME statement changes the size of the window in relation to start/current/end */
	MAX(PLAYER_RANKING) OVER (ORDER BY SUM(CHECKMATE)
		ROWS BETWEEN UNBOUNDED PRECEDING and CURRENT ROW) AS MAX_RANKING_RANGE,
	
	SUM(SUM(CHECKMATE)) OVER (ORDER BY PLAYER_RANKING DESC RANGE UNBOUNDED PRECEDING)
		/ SUM(SUM(CHECKMATE)) OVER () AS PROP_MATCHES_WON_BY_EQ OR_HIGHER_2,

	— CAST used to cast from default integer math to FP using ‘AS FLOAT’ or ‘::FLOAT’	
	CAST(COUNT(PLAYER_NAME) OVER (ORDER BY PLAYER_RANKING DESC RANGE UNBOUNDED PRECEDING)
		AS FLOAT) / COUNT(PLAYER_NAME) OVER ()::FLOAT AS PROP_PLAYERS_EQ_OR_HIGHER

FROM treehouse.chess_data_matches
GROUP BY PLAYER_NAME,
	PLAYER_RANKING,
	PLAYER_TEAM
— ORDER BY’s are part of the workshop
— ORDER BY 15 ASC !! 15th field as locator for Q4
— ORDER BY SUM(CHECKMATE) DESC — this orders by the highest wins
ORDER BY SUM(CHECKMATE)