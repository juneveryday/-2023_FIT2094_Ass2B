--*****PLEASE ENTER YOUR DETAILS BELOW*****
--T2-tsa-select.sql

--Student ID: 31994695
--Student Name: June Jin
--Unit Code: FIT2094
--Applied Class No: 4

/* Comments for your marker:




*/

/*2(a)*/ -- Done.

SELECT  t.town_id, 
        t.town_name, 
        p.poi_type_id, 
        pt.poi_type_descr, 
        COUNT(pt.poi_type_id) AS poi_count
FROM    tsa.town t
JOIN    tsa.point_of_interest p ON p.town_id = t.town_id
JOIN    tsa.poi_type pt ON pt.poi_type_id = p.poi_type_id
GROUP BY    t.town_id,
            t.town_name, 
            p.poi_type_id, 
            pt.poi_type_descr
HAVING      COUNT(pt.poi_type_id) > 1
ORDER BY    t.town_id,pt.poi_type_descr;



/*2(b)*/ -- Done.

SELECT  mb.member_id, 
        mb.member_gname ||' '|| mb.member_fname as MEMBER_NAME,
        mb.resort_id, 
        rs.resort_name,
        COUNT(mb2.member_id) AS NUMBER_OF_RECOMMENDATIONS
        
FROM tsa.member mb
JOIN tsa.member mb2 ON mb2.member_id_recby = mb.member_id
JOIN tsa.resort rs  ON rs.resort_id        = mb.resort_id

HAVING COUNT(mb2.member_id) = 
                                (
                                SELECT MAX(COUNT(mb2.member_id))
                                FROM tsa.member mb
                                JOIN tsa.member mb2 ON mb2.member_id_recby =  mb.member_id
                                JOIN tsa.resort rs  ON  rs.resort_id       =  mb.resort_id
                                GROUP BY 
                                    mb.member_id,
                                    mb.member_gname ||' '|| mb.member_fname,
                                    mb.resort_id,
                                    rs.resort_name
                                )
GROUP BY mb.member_id, mb.member_gname ||' '|| mb.member_fname, mb.resort_id, rs.resort_name
ORDER BY mb.resort_id, mb.member_id;



/*2(c)*/ -- Done.

SELECT  poi.poi_id, 
        poi.poi_name, 
        NVL(TO_CHAR(MAX(rv.review_rating), 0),'NR') AS max_rating, 
        NVL(TO_CHAR(MIN(rv.review_rating), 0),'NR') AS min_rating, 
        NVL(TO_CHAR(ROUND(AVG(rv.review_rating), 1), '0.0'), 'NR') AS avg_rating
        
FROM tsa.point_of_interest poi
LEFT JOIN tsa.review rv ON poi.poi_id = rv.poi_id
GROUP BY poi.poi_id, poi.poi_name
ORDER BY poi.poi_id;

        
/*2(d)*/  -- Done.

SELECT  poi_name,
        poi_type_descr,
        town_name,
        LPAD('Lat: '   || TO_CHAR(LTRIM(town_lat, '990.000000')) ||' Long: ' || TO_CHAR(LTRIM(town_long, '990.000000')),35, ' ') AS TOWN_LOCATION,
        (select count(r.poi_id) from tsa.review r where r.poi_id = poi.poi_id) AS REVIEW_COMPLETED, 
        CASE WHEN 
            (SELECT COUNT(r.poi_id) FROM tsa.review r WHERE r.poi_id = poi.poi_id) = 0
             THEN 'No reviews completed'
             ELSE TO_CHAR(ROUND((SELECT COUNT(r.poi_id) FROM tsa.review r WHERE r.poi_id = poi.poi_id)/(SELECT COUNT(*) FROM tsa.review) * 100,2)) || '%'
             END AS PERCENT_OF_REVIEWS

FROM tsa.point_of_interest poi
NATURAL JOIN tsa.poi_type
NATURAL JOIN tsa.town
ORDER BY town_name, (SELECT COUNT(r.poi_id) FROM tsa.review r WHERE r.poi_id = poi.poi_id) DESC, poi_name;

/*2(e)*/ -- Done.

SELECT  mb.resort_id, 
        rs.resort_name, 
        mb.member_no, 
        LTRIM(mb.member_gname || ' ' || mb.member_fname) as MEMBER_NAME,
        TO_CHAR(mb.member_date_joined,'DD-MON-YYYY') AS DATE_JOINED,
        RPAD(mb2.member_no || ' ' || mb2.member_gname || ' ' || mb2.member_fname, LENGTH(mb2.member_no || ' ' || mb2.member_gname || ' ' || mb2.member_fname)) as RECOMMENDED_BY_DETAILS,
        LPAD('$' || LTRIM(to_char(round(SUM(CASE WHEN mc.mc_paid_date IS NULL THEN 0 ELSE mc.mc_total END)))), 13) as TOTAL_CHARGES
        
FROM tsa.member mb
JOIN tsa.member_charge mc ON mc.member_id = mb.member_id 
JOIN tsa.member mb2 ON mb2.member_id  = mb.member_id_recby
JOIN tsa.resort rs  ON rs.resort_id   = mb.resort_id
JOIN tsa.town   tn  ON tn.town_id     = rs.town_id

WHERE
       mb.member_id_recby IS NOT NULL
AND    NOT (UPPER(tn.town_name)  = UPPER('Byron Bay') 
            AND 
            UPPER(tn.town_state) = UPPER('NSW'))
HAVING SUM(mc.mc_total) < ( select AVG(sum(mc2.mc_total))
                            from tsa.member_charge mc2 
                            join tsa.member mb3 on mb3.member_id = mc2.member_id
                            where mb3.resort_id = mb.resort_id
                            and mc2.mc_paid_date is not null
                            group by mb3.member_id
                           )
GROUP BY mb.resort_id, rs.resort_name, mb.member_no, mb.member_gname ||' '|| mb.member_fname, mb.member_date_joined, mb2.member_no || ' ' || mb2.member_gname || ' ' || mb2.member_fname
ORDER BY mb.resort_id, mb.member_no;



/*2(f)*/ -- Done.

SELECT rs.resort_id, 
       rs.resort_name, 
       poi.poi_name, 
       tn2.town_name AS POI_TOWN, 
       tn2.town_state AS POI_STATE, 
       NVL(TO_CHAR(poi.poi_open_time, 'HH:MI AM'), 'Not Applicable') AS POI_OPENING_TIME,
       TO_CHAR(geodistance(tn.town_lat,tn.town_long,tn2.town_lat,tn2.town_long), '990.0') || ' Kms' as DISTANCE
FROM tsa.resort rs
JOIN tsa.town tn ON tn.town_id = rs.town_id
JOIN tsa.town tn2 ON geodistance(tn.town_lat,tn.town_long,tn2.town_lat,tn2.town_long) <= 100.0
JOIN tsa.point_of_interest poi ON poi.town_id = tn2.town_id

ORDER BY rs.resort_name, TO_CHAR(geodistance(tn.town_lat,tn.town_long,tn2.town_lat,tn2.town_long), '990.0');
