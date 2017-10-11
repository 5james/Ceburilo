SELECT
 *
FROM
 ways_astar_bike;
 
 REFRESH MATERIALIZED VIEW ways_astar_bike;
 
 CREATE UNIQUE INDEX idx_ways_astar_bike ON ways_astar_bike (id, source, target, cost, reverse_cost, x1, y1, x2, y2);
 
 REFRESH MATERIALIZED VIEW CONCURRENTLY ways_astar_bike;

