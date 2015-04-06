SELECT distinct id16, count(DISTINCT place), count(place)
  FROM locationslatlon where place is not null group by 1 order by 2, 3;