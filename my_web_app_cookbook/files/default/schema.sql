CREATE TABLE IF NOT EXISTS counters (
 id int(11) NOT NULL AUTO_INCREMENT,
 count_date date NOT NULL,
 count_value int(11) NOT NULL DEFAULT '0',
 PRIMARY KEY (id),
 UNIQUE KEY count_date (count_date)
) ENGINE=InnoDB AUTO_INCREMENT=5;