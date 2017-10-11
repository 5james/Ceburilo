CREATE TABLE public.stations (
    uid BIGINT PRIMARY KEY,
    name text,
    x double precision, 
    y double precision, 
    the_geom geometry,
    nearest_source BIGINT REFERENCES public.ways_vertices_pgr (id)
);

