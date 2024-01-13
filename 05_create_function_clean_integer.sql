CREATE OR REPLACE FUNCTION keepcoding.fnc_clean_integer(p_integer INT64) RETURNS INT64 
AS(
  ( SELECT IFNULL(p_integer, -999999) )
);



--select keepcoding.fnc_clean_integer(null);

--select keepcoding.fnc_clean_integer(-190);

--select keepcoding.fnc_clean_integer(222);