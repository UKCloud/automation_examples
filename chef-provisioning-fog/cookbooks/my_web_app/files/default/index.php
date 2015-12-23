<?php
require_once("config.php")

// Connecting, selecting database
$link = mysql_connect($db_host, $db_user, $db_password)
    or die('Could not connect: ' . mysql_error());
echo 'Connected successfully';
mysql_select_db($db_name) or die('Could not select database');
