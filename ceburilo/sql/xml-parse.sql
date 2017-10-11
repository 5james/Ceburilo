CREATE OR REPLACE FUNCTION parseBikeStations() RETURNS boolean AS $$ 
DECLARE 
    xml_x xml[]; 
    xml_y xml[]; 
    xml_name xml[]; 
    xml_uid xml[];
    nb_xml xml := getXMLDocument('nb.xml');
    size int;
    nearest_source BIGINT;
BEGIN 

    SELECT xpath('/markers/country[@country="PL"]/city/place/@lat', getXMLDocument('nb.xml')) station_lat,
           xpath('/markers/country[@country="PL"]/city/place/@lng', getXMLDocument('nb.xml')) station_lng,
           xpath('/markers/country[@country="PL"]/city/place/@name', getXMLDocument('nb.xml'))::text station_name,
           xpath('/markers/country[@country="PL"]/city/place/@uid', getXMLDocument('nb.xml')) station_uid 
        INTO xml_y, xml_x, xml_name, xml_uid;
	
    SELECT array_length(xml_y, 1) into size;
    
	RAISE NOTICE '%', size; 
    
    IF array_length(xml_x, 1) <> size OR array_length(xml_name, 1) <> size THEN
    	RAISE EXCEPTION 'xml data fail';
    	RETURN FALSE;
    END IF;  
    
    FOR i in 1..size LOOP    
        SELECT SOURCE into nearest_source FROM ways ORDER BY ST_Distance(ST_StartPoint(the_geom), ST_SetSRID(ST_MakePoint(xml_x[i]::text::float8, xml_y[i]::text::float8), 4326), TRUE) ASC LIMIT 1;
        RAISE NOTICE 'i=%, uid=%, x=%, y=%, name=%, nearest source=%, the_geom=%',
                    i,
                    xml_uid[i]::text::bigint,
                    xml_x[i]::text::float8,
                    xml_y[i]::text::float8,
                    xml_name[i]::text,
                    nearest_source,
                    ST_SetSRID(ST_MakePoint(xml_x[i]::text::float8, xml_y[i]::text::float8), 4326); 
		INSERT INTO public.stations (uid, name, x, y, the_geom, nearest_source)
    		VALUES (xml_uid[i]::text::bigint,
                    xml_name[i]::text,
                    xml_x[i]::text::float8,
                    xml_y[i]::text::float8,
                    ST_SetSRID(ST_MakePoint(xml_x[i]::text::float8, xml_y[i]::text::float8), 4326),
                    nearest_source);
    END LOOP;
              
	RETURN TRUE;
END; 
$$ LANGUAGE plpgsql;

ALTER FUNCTION parseBikeStations() OWNER TO postgres;


SELECT *
FROM parseBikeStations();