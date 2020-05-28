/********************************************************************************
	This script will create a date dimension for a Snowflake database. You will
	need to adjust the recursive WITH clause to create the appropriate range
	of dates. 
*********************************************************************************/

DROP TABLE IF EXISTS DIM_DATE;

CREATE TABLE DIM_DATE AS
WITH DATES AS /* Use GENERATOR to generate range of dates. Adjust starting date and ROWCOUNT as necessary for the desired date range */
  (
     SELECT DATEADD ( DAY, SEQ4(), '1900-01-01' )::DATE AS DT
     FROM TABLE ( GENERATOR ( ROWCOUNT => 219511 ) )
  )
SELECT TO_NUMBER ( TO_VARCHAR ( DT, 'YYYYMMDD' ), '99999999' )                    AS DATE_KEY,
    DT                                                                            AS DATE_ACTUAL,
    TO_NUMBER ( TO_VARCHAR ( DT, 'YYYYMMDD' ), '99999999' ) - 18000000            AS YYYMMDD, /* Some old systems may use 7 digit dates */
    TO_VARCHAR ( DT, 'MMDDYYYY' )                                                 AS MMDDYYYY,
    TO_VARCHAR ( DT, 'MMYYYY' )                                                   AS MMYYYY,
    TO_VARCHAR ( DT, 'MMYY' )                                                     AS MMYY,
    TO_VARCHAR ( DT, 'MMMM DD, YYYY' )                                            AS MONTH_DD_YYYY,
    TO_VARCHAR ( DT, 'Mon DD, YYYY' )                                             AS MON_DD_YYYY,
    TO_VARCHAR ( DT, 'MM/DD/YYYY' )                                               AS MM_DD_YYYY_SLASH,
    TO_VARCHAR ( DT, 'MM-DD-YYYY' )                                               AS MM_DD_YYYY_HYPHEN,
    TO_VARCHAR ( DT, 'MM.DD.YYYY' )                                               AS MM_DD_YYYY_DOT,
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
      7, 'U')                                                                   AS DAY_NAME_LETTER,
    DATE_PART ( DAYOFWEEKISO, DT )                                              AS DAY_OF_WEEK,
    DAYOFMONTH ( DT )                                                           AS DAY_OF_MONTH,
    DATE_TRUNC ( 'DAY', DT ) - DATE_TRUNC ( 'QUARTER', DT ) + 1                 AS DAY_OF_QUARTER,
    DAYOFYEAR ( DT )                                                            AS DAY_OF_YEAR,
    DATE_PART ( WEEK, DT ) - DATE_PART ( WEEK, DATE_TRUNC ( 'MONTH', DT ) ) + 1 AS WEEK_OF_MONTH,
    WEEKOFYEAR ( DT )                                                           AS WEEK_OF_YEAR,
    DATE_PART ('MONTH', DT )                                                    AS MONTH_OF_YEAR,
    TO_VARCHAR ( DT, 'MMMM' )                                                   AS MONTH_NAME,
    TO_VARCHAR ( DT, 'Mon' )                                                    AS MONTH_NAME_ABBREVIATED,
    QUARTER ( DT )                                                              AS QUARTER_ACTUAL,
    DECODE ( QUARTER ( DT ),
      1, 'First',
      2, 'Second',
      3, 'Third',
      4, 'Fourth')                                                              AS QUARTER_NAME,
    DECODE ( QUARTER ( DT ),
      1, 'Q1',
      2, 'Q2',
      3, 'Q3',
      4, 'Q4')                                                                  AS QUARTER_NAME_ABBREVIATED,
    YEAR ( DT )                                                                 AS YEAR_ACTUAL,
    DATE_TRUNC ( 'WEEK', DT )                                                   AS FIRST_DAY_OF_WEEK,
    LAST_DAY ( DT, 'WEEK' )                                                     AS LAST_DAY_OF_WEEK,
    DATE_TRUNC ( 'MONTH', DT )                                                  AS FIRST_DAY_OF_MONTH,
    LAST_DAY ( DT, 'MONTH' )                                                    AS LAST_DAY_OF_MONTH,
    DATE_TRUNC ( 'QUARTER', DT )                                                AS FIRST_DAY_OF_QUARTER,
    LAST_DAY ( DT, 'QUARTER' )                                                  AS LAST_DAY_OF_QUARTER,
    CASE WHEN DATE_PART ( DAYOFWEEKISO, DT )  IN ( 6, 7 ) THEN 'Y' ELSE 'N' END AS IS_WEEKEND
FROM DATES;