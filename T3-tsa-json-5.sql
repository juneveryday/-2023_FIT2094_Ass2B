--*****PLEASE ENTER YOUR DETAILS BELOW*****
--T3-tsa-json.sql

--Student ID: 31994695
--Student Name: June Jin
--Unit Code: FIT2094
--Applied Class No: 4

/* Comments for your marker:

*/

/*3(a)*/
SET PAGESIZE 200

SELECT 
     JSON_OBJECT (  '_id'           VALUE tn.town_id, 
                    'name'          VALUE tn.town_name || ', ' ||tn.town_state,
                    'location'      VALUE JSON_OBJECT (
                                                        'latitude' VALUE tn.town_lat,
                                                        'longitude'VALUE tn.town_long
                                                        ),
                    'avg_temperature' VALUE JSON_OBJECT (
                                                        'summer'   VALUE tn.town_avg_summer_temp,
                                                        'winter'   VALUE tn.town_avg_winter_temp
                                                        ),
                    'no_of_resorts' VALUE  (
                                            SELECT COUNT(*) 
                                            FROM tsa.resort rs 
                                            WHERE rs.town_id = tn.town_id 
                                            GROUP BY rs.town_id
                                            ),
                     'resorts' VALUE JSON_ARRAYAGG( 
                                            JSON_OBJECT(
                                                        'id'            VALUE rs.resort_id,
                                                        'name'          VALUE rs.resort_name,
                                                        'address'       VALUE rs.resort_street_address,
                                                        'phone'         VALUE rs.resort_phone,
                                                        'year_built'    VALUE to_number(to_char(rs.resort_yr_built_purch,'yyyy')),
                                                        'company_name'  VALUE cp.company_name
                                                        )
                                                        )FORMAT JSON)
                                                    || ',' 
FROM tsa.town tn
JOIN tsa.resort rs ON tn.town_id = rs.town_id
JOIN tsa.company cp ON rs.company_abn = cp.company_abn
group by tn.town_id, tn.town_name || ', ' ||tn.town_state, tn.town_lat, tn.town_long, tn.town_avg_summer_temp, tn.town_avg_winter_temp;
