/********************************************************************************
	This script will create a date dimension for a Snowflake database. You will
	need to adjust the WITH clause to create the appropriate range
	of dates. 
*********************************************************************************/

CREATE OR REPLACE TABLE DIM_DATE 
  ( 
     DATE_KEY                 NUMBER(8, 0), 
     DATE_ACTUAL              DATE, 
     YYYMMDD                  NUMBER(7, 0), 
     MMDDYYYY                 CHAR(8), 
     MMYYYY                   CHAR(6), 
     MMYY                     CHAR(4), 
     MMYY_SLASH               CHAR(5),
     MONTH_DD_YYYY            VARCHAR(18), 
     MON_DD_YYYY              CHAR(12), 
     MM_DD_YYYY_SLASH         CHAR(10), 
     MM_DD_YYYY_HYPHEN        CHAR(10), 
     MM_DD_YYYY_DOT           CHAR(10), 
     DAY_NAME                 VARCHAR(9), 
     DAY_NAME_ABBREVIATED     CHAR(3), 
     DAY_NAME_LETTER          CHAR(1), 
     DAY_OF_WEEK              NUMBER(1, 0), 
     DAY_OF_MONTH             NUMBER(2, 0), 
     DAY_OF_QUARTER           NUMBER(2, 0), 
     DAY_OF_YEAR              NUMBER(3, 0), 
     WEEK_OF_MONTH            NUMBER(2, 0), 
     WEEK_OF_QUARTER          NUMBER(2, 0),
     WEEK_OF_YEAR             NUMBER(2, 0), 
     MONTH_OF_YEAR            NUMBER(2, 0), 
     MONTH_NAME               VARCHAR(9), 
     MONTH_NAME_ABBREVIATED   CHAR(3), 
     QUARTER_ACTUAL           NUMBER(1, 0), 
     QUARTER_NAME             VARCHAR(6), 
     QUARTER_NAME_ABBREVIATED CHAR(2), 
     YEAR_ACTUAL              NUMBER(4, 0), 
     FIRST_DAY_OF_WEEK        DATE, 
     LAST_DAY_OF_WEEK         DATE, 
     FIRST_DAY_OF_MONTH       DATE, 
     LAST_DAY_OF_MONTH        DATE, 
     FIRST_DAY_OF_QUARTER     DATE, 
     LAST_DAY_OF_QUARTER      DATE, 
     IS_WEEKEND               CHAR(1), 
     IS_HOLIDAY               CHAR(1) 
  ) ; 

/* Use GENERATOR to generate range of dates. Adjust starting date and ROWCOUNT as necessary for the desired date range */
CREATE OR REPLACE TEMPORARY TABLE DATES AS
SELECT DATEADD ( DAY, SEQ4(), '1900-01-01' )::DATE AS DT
FROM TABLE ( GENERATOR ( ROWCOUNT => 73414 ) ) ;

/* Create date dimension temp table */
CREATE OR REPLACE TEMPORARY TABLE DIM_DATE_TEMP AS
SELECT TO_NUMBER ( TO_CHAR ( DT, 'YYYYMMDD' ), '99999999' )                       AS DATE_KEY,
    DT                                                                            AS DATE_ACTUAL,
    TO_NUMBER ( TO_CHAR ( DT, 'YYYYMMDD' ), '99999999' ) - 18000000               AS YYYMMDD, /* Some old systems may use 7 digit dates */
    TO_CHAR ( DT, 'MMDDYYYY' )                                                    AS MMDDYYYY,
    TO_CHAR ( DT, 'MMYYYY' )                                                      AS MMYYYY,
    TO_CHAR ( DT, 'MMYY' )                                                        AS MMYY,
    TO_CHAR ( DT, 'MM/YY' )                                                       AS MMYY_SLASH,
    TO_CHAR ( DT, 'MMMM DD, YYYY' )                                               AS MONTH_DD_YYYY,
    TO_CHAR ( DT, 'Mon DD, YYYY' )                                                AS MON_DD_YYYY,
    TO_CHAR ( DT, 'MM/DD/YYYY' )                                                  AS MM_DD_YYYY_SLASH,
    TO_CHAR ( DT, 'MM-DD-YYYY' )                                                  AS MM_DD_YYYY_HYPHEN,
    TO_CHAR ( DT, 'MM.DD.YYYY' )                                                  AS MM_DD_YYYY_DOT,
    DECODE ( DATE_PART ( DAYOFWEEKISO, DT ),
      1, 'Monday',
      2, 'Tuesday',
      3, 'Wednesday',
      4, 'Thursday',
      5, 'Friday',
      6, 'Saturday',
      7, 'Sunday')                                                                AS DAY_NAME,
    DAYNAME ( DT )                                                                AS DAY_NAME_ABBREVIATED,
    DECODE ( DATE_PART ( DAYOFWEEKISO, DT ),
      1, 'M',
      2, 'T',
      3, 'W',
      4, 'R',
      5, 'F',
      6, 'S',
      7, 'U')                                                                     AS DAY_NAME_LETTER,
    DATE_PART ( DAYOFWEEKISO, DT )                                                AS DAY_OF_WEEK,
    DAYOFMONTH ( DT )                                                             AS DAY_OF_MONTH,
    DATE_TRUNC ( 'DAY', DT ) - DATE_TRUNC ( 'QUARTER', DT ) + 1                   AS DAY_OF_QUARTER,
    DAYOFYEAR ( DT )                                                              AS DAY_OF_YEAR,
    DATE_PART ( WEEK, DT ) - DATE_PART ( WEEK, DATE_TRUNC ( 'MONTH', DT ) ) + 1   AS WEEK_OF_MONTH,
    DATE_PART ( WEEK, DT ) - DATE_PART ( WEEK, DATE_TRUNC ( 'QUARTER', DT ) ) + 1 AS WEEK_OF_QUARTER,
    WEEKOFYEAR ( DT )                                                             AS WEEK_OF_YEAR,
    DATE_PART ('MONTH', DT )                                                      AS MONTH_OF_YEAR,
    TO_CHAR ( DT, 'MMMM' )                                                        AS MONTH_NAME,
    TO_CHAR ( DT, 'Mon' )                                                         AS MONTH_NAME_ABBREVIATED,
    QUARTER ( DT )                                                                AS QUARTER_ACTUAL,
    DECODE ( QUARTER ( DT ),
      1, 'First',
      2, 'Second',
      3, 'Third',
      4, 'Fourth')                                                                AS QUARTER_NAME,
    DECODE ( QUARTER ( DT ),
      1, 'Q1',
      2, 'Q2',
      3, 'Q3',
      4, 'Q4')                                                                    AS QUARTER_NAME_ABBREVIATED,
    YEAR ( DT )                                                                   AS YEAR_ACTUAL,
    DATE_TRUNC ( 'WEEK', DT )                                                     AS FIRST_DAY_OF_WEEK,
    LAST_DAY ( DT, 'WEEK' )                                                       AS LAST_DAY_OF_WEEK,
    DATE_TRUNC ( 'MONTH', DT )                                                    AS FIRST_DAY_OF_MONTH,
    LAST_DAY ( DT, 'MONTH' )                                                      AS LAST_DAY_OF_MONTH,
    DATE_TRUNC ( 'QUARTER', DT )                                                  AS FIRST_DAY_OF_QUARTER,
    LAST_DAY ( DT, 'QUARTER' )                                                    AS LAST_DAY_OF_QUARTER,
    CASE WHEN DATE_PART ( DAYOFWEEKISO, DT )  IN ( 6, 7 ) THEN 'Y' ELSE 'N' END   AS IS_WEEKEND
FROM DATES ;

/* Create holidays temp table */
CREATE OR REPLACE TEMPORARY TABLE HOLIDAYS AS
SELECT DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 1 AND DAY_OF_MONTH = 1
UNION ALL
SELECT MAX ( DATE_KEY ) AS DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 5 AND DAY_OF_WEEK = 1 GROUP BY YEAR_ACTUAL, MONTH_OF_YEAR
UNION ALL
SELECT DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 7 AND DAY_OF_MONTH = 4
UNION ALL
SELECT MIN ( DATE_KEY ) AS DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 9 AND DAY_OF_WEEK = 1 GROUP BY YEAR_ACTUAL, MONTH_OF_YEAR
UNION ALL 
SELECT DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 11 AND WEEK_OF_MONTH = 4 AND DAY_OF_WEEK = 4 
UNION ALL 
SELECT DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 11 AND WEEK_OF_MONTH = 4 AND DAY_OF_WEEK = 5
UNION ALL
SELECT DATE_KEY FROM DIM_DATE_TEMP WHERE MONTH_OF_YEAR = 12 AND DAY_OF_MONTH = 25 ;

INSERT
INTO DIM_DATE
  (
    DATE_KEY,
    DATE_ACTUAL,
    YYYMMDD,
    MMDDYYYY,
    MMYYYY,
    MMYY,
    MMYY_SLASH,
    MONTH_DD_YYYY,
    MON_DD_YYYY,
    MM_DD_YYYY_SLASH,
    MM_DD_YYYY_HYPHEN,
    MM_DD_YYYY_DOT,
    DAY_NAME,
    DAY_NAME_ABBREVIATED,
    DAY_NAME_LETTER,
    DAY_OF_WEEK,
    DAY_OF_MONTH,
    DAY_OF_QUARTER,
    DAY_OF_YEAR,
    WEEK_OF_MONTH,
    WEEK_OF_QUARTER,
    WEEK_OF_YEAR,
    MONTH_OF_YEAR,
    MONTH_NAME,
    MONTH_NAME_ABBREVIATED,
    QUARTER_ACTUAL,
    QUARTER_NAME,
    QUARTER_NAME_ABBREVIATED,
    YEAR_ACTUAL,
    FIRST_DAY_OF_WEEK,
    LAST_DAY_OF_WEEK,
    FIRST_DAY_OF_MONTH,
    LAST_DAY_OF_MONTH,
    FIRST_DAY_OF_QUARTER,
    LAST_DAY_OF_QUARTER,
    IS_WEEKEND,
    IS_HOLIDAY
  )
SELECT DDT.DATE_KEY,
  DDT.DATE_ACTUAL,
  DDT.YYYMMDD,
  DDT.MMDDYYYY,
  DDT.MMYYYY,
  DDT.MMYY,
  DDT.MMYY_SLASH,
  DDT.MONTH_DD_YYYY,
  DDT.MON_DD_YYYY,
  DDT.MM_DD_YYYY_SLASH,
  DDT.MM_DD_YYYY_HYPHEN,
  DDT.MM_DD_YYYY_DOT,
  DDT.DAY_NAME,
  DDT.DAY_NAME_ABBREVIATED,
  DDT.DAY_NAME_LETTER,
  DDT.DAY_OF_WEEK,
  DDT.DAY_OF_MONTH,
  DDT.DAY_OF_QUARTER,
  DDT.DAY_OF_YEAR,
  DDT.WEEK_OF_MONTH,
  DDT.WEEK_OF_QUARTER,
  DDT.WEEK_OF_YEAR,
  DDT.MONTH_OF_YEAR,
  DDT.MONTH_NAME,
  DDT.MONTH_NAME_ABBREVIATED,
  DDT.QUARTER_ACTUAL,
  DDT.QUARTER_NAME,
  DDT.QUARTER_NAME_ABBREVIATED,
  DDT.YEAR_ACTUAL,
  DDT.FIRST_DAY_OF_WEEK,
  DDT.LAST_DAY_OF_WEEK,
  DDT.FIRST_DAY_OF_MONTH,
  DDT.LAST_DAY_OF_MONTH,
  DDT.FIRST_DAY_OF_QUARTER,
  DDT.LAST_DAY_OF_QUARTER,
  DDT.IS_WEEKEND,
  CASE WHEN H.DATE_KEY IS NOT NULL THEN 'Y' ELSE 'N' END AS IS_HOLIDAY
FROM DIM_DATE_TEMP DDT
LEFT JOIN HOLIDAYS H
ON DDT.DATE_KEY = H.DATE_KEY 
ORDER BY DDT.DATE_KEY ;