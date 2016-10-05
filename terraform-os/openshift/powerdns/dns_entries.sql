# Delete existing entries before inserting new ones
${delete}
DELETE FROM records WHERE domain_id='1' AND name='${cluster_fqdn}';
# Insert records for the current servers in the OpenShift deploy
${insert}
INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES (1,'${cluster_fqdn}','${cluster_address}','A',120,NULL);
