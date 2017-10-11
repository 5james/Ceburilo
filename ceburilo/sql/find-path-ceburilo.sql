DROP FUNCTION findPathCeburilo_astar(arg_x1 double precision, arg_y1 double precision, arg_x2 double precision, arg_y2 double precision);
CREATE OR REPLACE FUNCTION findPathCeburilo_astar(arg_x1 double precision, arg_y1 double precision, arg_x2 double precision, arg_y2 double precision)
RETURNS 
  TABLE (
           -- seq integer,
           -- path_seq integer,
           -- node bigint,
           -- edge bigint,
           -- gid bigint,
           -- class_id integer,
           -- length double precision,
           -- length_m double precision,
           -- name text,
           -- source bigint,
           -- target bigint,
           -- x1 double precision,
           -- y1 double precision,
           -- x2 double precision,
           -- y2 double precision,
           -- cost double precision,
           -- agg_cost double precision,
           -- reverse_cost double precision,
           -- cost_s double precision,
           -- reverse_cost_s double precision,
           -- oneway integer,
           -- osm_id bigint,
           -- source_osm bigint,
           -- target_osm bigint,
           -- the_geom geometry,
           x double precision,
           y double precision,
           seqq integer
           )
  AS $$ 
DECLARE 
  var_r record; 
    -- i integer;
    iteration integer := 1;
    
  bike_average_speed_kmh double precision := 12;
    max_rent_time_h double precision := 0.33;
    max_distance_km double precision := bike_average_speed_kmh * max_rent_time_h;    
    max_distance_m double precision := bike_average_speed_kmh * max_rent_time_h * 1000;
    
    list_of_stations stations[] = ARRAY[]::stations[];    
    
    start_station stations;
    final_station stations;
    
    current_station stations;
    current_path record;
    current_path_length double precision := 0;
    
    minimum_left double precision := 0;
    
    temp_geom geometry;
    temp_station stations;
    processing_stations stations[];
    temp_minimum_left double precision := 0;
    best_candidate stations;
    best_candidate_found boolean := false;
    
    pre_main_path_geom geometry;
    
    path_found boolean := false;
BEGIN 
    -- get nearest stations of beginning and ending
  SELECT * INTO start_station
        FROM stations
        ORDER BY ST_Distance(stations.the_geom, ST_SetSRID(ST_MakePoint(arg_x1, arg_y1), 4326), TRUE) ASC LIMIT 1;  
  SELECT * INTO final_station
        FROM stations
        ORDER BY ST_Distance(stations.the_geom, ST_SetSRID(ST_MakePoint(arg_x2, arg_y2), 4326), TRUE) ASC LIMIT 1;
        
  raise notice '%\n%', start_station, final_station;

  list_of_stations := array_append(list_of_stations, start_station);
    
    pre_main_path_geom := ST_SetSRID(ST_MakePoint(arg_x1, arg_y1), 4326);
        
    -- calculate path from start point to first station
    FOR var_r IN(SELECT *
                FROM pgr_astar('SELECT * FROM ways_astar',
                             (SELECT SOURCE
                                FROM ways
                                          ORDER BY ST_Distance(ST_StartPoint(the_geom), ST_SetSRID(ST_MakePoint(arg_x1, arg_y1), 4326), TRUE) ASC LIMIT 1),
                                         start_station.nearest_source) AS pt
              JOIN ways rd ON pt.edge = rd.gid
                 )
               LOOP
                  IF var_r.seq = 1 THEN
                        -- save first x,y
                        --x := var_r.x1;
                        --y := var_r.y1;
                        seqq := iteration;
                        RETURN NEXT;
                    END IF;
                  -- RAISE NOTICE '1    %', var_r.seq;
                    x := var_r.x2;
                    y := var_r.y2;
                    seqq := iteration;
                    RETURN NEXT;
               END LOOP;
    iteration := iteration + 1;
    -- RAISE NOTICE 'START CALCULATED';


-- ----------------------------------------------------------------------------------------------------------------------

  -- MAIN ALGORITHM
    
    current_station := start_station;
  minimum_left := 0;
    FOR var_r IN(SELECT *
                FROM pgr_astar('SELECT * FROM ways_astar_bike',
                             current_station.nearest_source,
                                         final_station.nearest_source) AS pt
              JOIN ways rd ON pt.edge = rd.gid
                 )
               LOOP
                  -- RAISE NOTICE '2    %', var_r.seq;
                    minimum_left := minimum_left + var_r.length_m;
                    pre_main_path_geom := ST_Union(pre_main_path_geom, var_r.the_geom);
               END LOOP;
  -- raise notice 'min=% max=%', minimum_left, max_distance_m;
    
    <<smaller>>
    WHILE minimum_left > max_distance_m LOOP
    
      temp_geom := st_buffer(pre_main_path_geom::geography, 300);
        processing_stations := ARRAY[]::stations[];
        raise notice '%', temp_geom;
        FOR temp_station in SELECT * 
          FROM stations
            WHERE st_within(the_geom, temp_geom)=true 
            LOOP
              raise notice 'processing station %', temp_station;
              processing_stations := array_append(processing_stations, temp_station);
                
                temp_minimum_left := 0;
                
                -- calculate path from current point to temp_point and determine if path.length < max_distance_m
                FOR var_r IN(SELECT *
            FROM pgr_astar('SELECT * FROM ways_astar_bike',
                          current_station.nearest_source,
                                    temp_station.nearest_source) AS pt
          JOIN ways rd ON pt.edge = rd.gid
                 )
                LOOP
                  -- RAISE NOTICE '2    %', var_r.seq;
                    temp_minimum_left := temp_minimum_left + var_r.length_m;
                END LOOP; 
                
                IF temp_minimum_left < max_distance_m THEN
                    -- temp_station.length < max_distance_m then calculate path between temp_station to final to determine length
                    
                    temp_minimum_left := 0;
                    
                    FOR var_r IN(SELECT *
                        FROM pgr_astar('SELECT * FROM ways_astar_bike',
                                        temp_station.nearest_source,
                                        final_station.nearest_source) AS pt
                        JOIN ways rd ON pt.edge = rd.gid
                     )
                    LOOP
                        -- RAISE NOTICE '2    %', var_r.seq;
                        temp_minimum_left := temp_minimum_left + var_r.length_m;
                    END LOOP; 
                    
                    -- check if temp_station is best station to go through
                    IF temp_minimum_left < minimum_left AND temp_minimum_left <> 0 THEN
                      minimum_left := temp_minimum_left;
                        best_candidate := temp_station;
                        best_candidate_found := true;
                    END IF;
                    
                    
                END IF;
                    
            END LOOP;
         
         IF best_candidate_found = true THEN
          best_candidate_found := false;
          current_station := best_candidate;
            list_of_stations := array_append(list_of_stations, current_station);
         ELSE
          -- reset all values and go with bigger algorithm
          minimum_left = max_distance_m + 1;
            current_station := start_station;
            list_of_stations := ARRAY[]::stations[];
            list_of_stations := array_append(list_of_stations, start_station);
            raise notice 'SMALLER FAILED GO WITH BIGGER';
            EXIT smaller;
         END IF;
         raise notice 'end iteration';
    END LOOP smaller;
    
    <<bigger>>
    WHILE minimum_left > max_distance_m LOOP
    
      temp_geom := st_intersection (st_buffer(ST_Line_Interpolate_Point(ST_MakeLine( (SELECT the_geom FROM stations WHERE uid=2585306), (SELECT the_geom FROM stations WHERE uid=2585790)), 0.5)::geography, (SELECT st_length/2 FROM ST_Length(ST_MakeLine( (SELECT the_geom FROM stations WHERE uid=2585306), (SELECT the_geom FROM stations WHERE uid=2585790))::geography)))::geometry, ST_Buffer(ST_MakeLine( (SELECT the_geom FROM stations WHERE uid=2585306), (SELECT the_geom FROM stations WHERE uid=2585790))::geography, (SELECT st_length/4 FROM ST_Length(ST_MakeLine( (SELECT the_geom FROM stations WHERE uid=2585306), (SELECT the_geom FROM stations WHERE uid=2585790))::geography)))::geometry);
        processing_stations := ARRAY[]::stations[];
        
        FOR temp_station in SELECT * 
          FROM stations
            WHERE st_within(the_geom, temp_geom)=true 
            LOOP
              raise notice 'processing station %', temp_station;
              processing_stations := array_append(processing_stations, temp_station);
                
                temp_minimum_left := 0;
                
                -- calculate path from current point to temp_point and determine if path.length < max_distance_m
                FOR var_r IN(SELECT *
            FROM pgr_astar('SELECT * FROM ways_astar_bike',
                          current_station.nearest_source,
                                    temp_station.nearest_source) AS pt
          JOIN ways rd ON pt.edge = rd.gid
                 )
                LOOP
                  -- RAISE NOTICE '2    %', var_r.seq;
                    temp_minimum_left := temp_minimum_left + var_r.length_m;
                END LOOP; 
                
                IF temp_minimum_left < max_distance_m THEN
                    -- temp_station.length < max_distance_m then calculate path between temp_station to final to determine length
                    
                    temp_minimum_left := 0;
                    
                    FOR var_r IN(SELECT *
                        FROM pgr_astar('SELECT * FROM ways_astar_bike',
                                        temp_station.nearest_source,
                                        final_station.nearest_source) AS pt
                        JOIN ways rd ON pt.edge = rd.gid
                     )
                    LOOP
                        -- RAISE NOTICE '2    %', var_r.seq;
                        temp_minimum_left := temp_minimum_left + var_r.length_m;
                    END LOOP; 
                    
                    -- check if temp_station is best station to go through
                    IF temp_minimum_left < minimum_left AND temp_minimum_left <> 0 THEN
                      minimum_left := temp_minimum_left;
                        best_candidate := temp_station;
                        best_candidate_found := true;
                    END IF;
                    
                    
                END IF;
                    
            END LOOP;
         
         IF best_candidate_found = true THEN
          best_candidate_found := false;
          current_station := best_candidate;
            list_of_stations := array_append(list_of_stations, current_station);
            
         END IF;
         raise notice 'end iteration';
    END LOOP bigger;
  
    -- RAISE NOTICE 'PATH CALCULATED % %', start_station.nearest_source, final_station.nearest_source;
              
-- ----------------------------------------------------------------------------------------------------------------------          
     
     list_of_stations := array_append(list_of_stations, final_station);
     
     
    -- return path between stations 
    x := list_of_stations[1].x;
    y := list_of_stations[1].y;
    RETURN NEXT;
    <<outer>>
    FOR i IN 1..(array_length(list_of_stations, 1)-1)
    LOOP
      <<inner>>
      FOR var_r IN(SELECT *
            FROM pgr_astar('SELECT * FROM ways_astar_bike',
                           list_of_stations[i].nearest_source,
                                    list_of_stations[i+1].nearest_source) AS pt
          JOIN ways rd ON pt.edge = rd.gid
                  )
    LOOP
      IF var_r.seq = 1 THEN
              -- save first x,y
              x := var_r.x1;
              y := var_r.y1;
              seqq := iteration;
            RETURN NEXT;
          END IF;
          -- RAISE NOTICE '1    %', var_r.seq;
      x := var_r.x2;
          y := var_r.y2;
            seqq := iteration;
            RETURN NEXT;
      END LOOP inner;
      RETURN NEXT;
      x := list_of_stations[i+1].x;
   	  y := list_of_stations[i+1].y;
      RETURN NEXT;
      iteration := iteration + 1;
    END LOOP outer;

     
    -- calculate path from last station to end point
    FOR var_r IN(SELECT *
                FROM pgr_astar('SELECT * FROM ways_astar',
                                         final_station.nearest_source,
                             (SELECT SOURCE
                                FROM ways
                                ORDER BY ST_Distance(ST_StartPoint(the_geom), ST_SetSRID(ST_MakePoint(arg_x2, arg_y2), 4326), TRUE) ASC LIMIT 1)) AS pt
              JOIN ways rd ON pt.edge = rd.gid
                 )
        LOOP
          IF var_r.seq = 1 THEN
                        -- save first x,y
                        x := var_r.x1;
                        y := var_r.y1;
                        seqq := iteration;
                        RETURN NEXT;
                    END IF;
                  -- RAISE NOTICE '3    %', var_r.seq;
                    x := var_r.x2;
                    y := var_r.y2;
                    seqq := iteration;
                    RETURN NEXT;
               END LOOP;
  raise notice '%', list_of_stations;
    -- RAISE NOTICE 'END CALCULATED';
END; 
$$ LANGUAGE plpgsql;

ALTER FUNCTION findPathCeburilo_astar(arg_x1 double precision, arg_y1 double precision, arg_x2 double precision, arg_y2 double precision) OWNER TO postgres;

 
-- SELECT * FROM findPathCeburilo_astar(20.9627559654, 52.2584414385, 21.0230338762, 52.2227808424);

-- COPY (SELECT y, x FROM findPathCeburilo_astar(20.9627559654, 52.2584414385, 21.0230338762, 52.2227808424)) TO '//Library/PostgreSQL/9.6/data/xmldir/myfile6.csv' ;

-- ([0-9]*.[0-9]*), ([0-9]*.[0-9]*)
-- {lat: $1, lng: $2},


