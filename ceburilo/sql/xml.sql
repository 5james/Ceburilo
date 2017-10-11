SELECT xpath('/my:a/text()', '<my:a xmlns:my="http://example.com">test</my:a>', ARRAY[ARRAY['my', 'http://example.com']]);

 ---------------------------------------------------------------------------------

SELECT name,
       setting
FROM pg_settings
WHERE name='data_directory';

 ---------------------------------------------------------------------------------
 --create the function to load xml doc

CREATE OR REPLACE FUNCTION getXMLDocument(p_filename character varying) RETURNS xml AS $$ ---we set the end read to some big number
-- because we are too lazy to grab the length
-- and it will cut of at the EOF anyway

SELECT CAST(pg_read_file(E'xmldir/' || $1 ,0, 100000000) AS xml); $$ LANGUAGE 'sql' VOLATILE SECURITY DEFINER;


ALTER FUNCTION getxmldocument(character varying) OWNER TO postgres;

 ---------------------------------------------------------------------------------

SELECT *
FROM getXMLDocument('nb.xml');

 ---------------------------------------------------------------------------------

SELECT xml_is_well_formed(getXMLDocument('nb.xml')::text);

 ---------------------------------------------------------------------------------
 
 WITH x AS
  (SELECT getXMLDocument('nb.xml') AS t)
  (SELECT xpath('/markers/country/@country', xml_node) country,
          xpath('/place/@lat', lista_miast) city,
          xpath('/place/@lng', lista_miast) city,
          xpath('/place/@name', lista_miast) city
   FROM
     (SELECT unnest(xpath('/markers/country/city/place', t)) lista_miast,
             t xml_node
      FROM x) q);
      
 ---------------------------------------------------------------------------------

WITH x AS
  (SELECT getXMLDocument('nb.xml') AS t)
  (SELECT xpath('/markers/country/@country', xml_node) country,
          xpath('/place/@lat', lista_miast) station_lat,
          xpath('/place/@lng', lista_miast) station_lng,
          xpath('/place/@name', lista_miast)::text station_name
   FROM
     (SELECT unnest(xpath('/markers/country/city/place', t)) lista_miast,
             t xml_node
      FROM x) q);
      
---------------------------------------------------------------------------------



  SELECT xpath('/markers/country[@country="PL"]/city/place/@lat', getXMLDocument('nb.xml')) station_lat,
          xpath('/markers/country[@country="PL"]/city/place/@lng', getXMLDocument('nb.xml')) station_lng,
          xpath('/markers/country[@country="PL"]/city/place/@name', getXMLDocument('nb.xml'))::text station_name;



 ---------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION parseBikeStations() RETURNS boolean AS $$ 
DECLARE 
    xml_x float8; 
    xml_y float8;
    xml_name text;
BEGIN 
	WITH x AS
      (SELECT getXMLDocument('nb.xml') AS t)
      (SELECT xpath('/markers/country/@country', xml_node) country,
              xpath('/place/@lat', lista_miast)::float8   station_lat,
              xpath('/place/@lng', lista_miast)   station_lng,
              xpath('/place/@name', lista_miast)  station_name 
         INTO
       	   xml_y, xml_x, xml_name
       FROM
         (SELECT unnest(xpath('/markers/country/city/place', t)) lista_miast,
                 t xml_node
          FROM x) q 
       ); 
          
     
	RAISE NOTICE '%', xml_y; 
          
	RETURN TRUE;
END; 
$$ LANGUAGE plpgsql;

ALTER FUNCTION parseBikeStations() OWNER TO postgres;


SELECT *
FROM parseBikeStations();

 ---------------------------------------------------------------------------------
