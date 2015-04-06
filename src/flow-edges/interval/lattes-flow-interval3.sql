# WORK

Total 147.650
Brasil 144.435 (98%)

SELECT count(distinct country_ascii)
  FROM locationslatlon where kind = 'work';

SELECT count(distinct country_ascii)
  FROM locationslatlon where kind = 'work' and country_ascii = 'brazil';

SELECT kind, city_ascii, count(city_ascii)
  FROM locationslatlon where kind = 'work' group by kind, city_ascii order by 3;

SELECT kind, country_ascii, count(country_ascii)
  FROM locationslatlon where kind = 'work' group by kind, country_ascii order by 3;

# Birth

Total 186434
Brasil 196035 (95%)

SELECT count(distinct country_ascii)
  FROM locationslatlon where kind = 'birth'
union
SELECT count(distinct country_ascii)
  FROM locationslatlon where kind = 'birth' and country_ascii = 'brazil';

SELECT kind, city_ascii, count(city_ascii)
  FROM locationslatlon where kind = 'birth' group by kind, city_ascii order by 3;

SELECT kind, country_ascii, count(country_ascii)
  FROM locationslatlon where kind = 'birth' group by kind, country_ascii order by 3;




SELECT country_ascii, count(DISTINCT place_ascii)
  FROM locationslatlon where country_ascii != 'brazil' and place is not null group by country_ascii order by 2;

SELECT country_ascii, count(DISTINCT place_ascii)
  FROM locationslatlon where country_ascii = 'brazil' and place is not null group by country_ascii
# Brasil 1473 (1473/2103 70%)

SELECT count(DISTINCT place_ascii) FROM locationslatlon;
# Total 2103

