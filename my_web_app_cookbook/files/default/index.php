<?php
require_once("config.php");

$mysqli = new mysqli($db_host, $db_user,  $db_password, $db_name);
if ($mysqli->connect_errno) {

    echo "Error: Failed to make a MySQL connection, here is why: \n";
    echo "Errno: " . $mysqli->connect_errno . "\n";
    echo "Error: " . $mysqli->connect_error . "\n";
    exit;
}

if (!$mysqli->query("INSERT IGNORE INTO counters (count_date) VALUES (CURRENT_DATE())") ||
    !$mysqli->query("UPDATE counters SET count_value=count_value+1 WHERE count_date=CURRENT_DATE()")) {

    echo "Error: Failed to increment counters, here is why: \n";
    echo "Errno: " . $mysqli->connect_errno . "\n";
    echo "Error: " . $mysqli->connect_error . "\n";
    exit;
}

$res = $mysqli->query("SELECT count_value FROM counters WHERE count_date = CURRENT_DATE()");
$today = $res->fetch_assoc();

$res = $mysqli->query("SELECT WEEK(count_date) AS week_num, SUM(count_value) AS week_count FROM counters GROUP BY 1 HAVING week_num=WEEK(CURRENT_DATE())");
$week = $res->fetch_assoc();

$res = $mysqli->query("SELECT MONTH(count_date) AS month_num, SUM(count_value) AS month_count FROM counters GROUP BY 1 HAVING month_num=MONTH(CURRENT_DATE())");
$month = $res->fetch_assoc();
?>
<html>
<head>
<title>Simple PHP Counter Web App</title>
</head>
<body>
	<table width="100%" height="100%">
	<tr><td align="center" valign="center">Today: <?php echo $today['count_value'] ?><br>
	This Week: <?php echo $week['week_count'] ?><br>
	This Month: <?php echo $month['month_count'] ?></td>
	</tr>
    <tr><td align="right"><?php echo $_SERVER["SERVER_ADDR"] ?></td></tr>
	</table>
</body>
</html>