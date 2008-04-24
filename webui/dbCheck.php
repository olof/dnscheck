<?php
	require_once('constants.php');

	function dbCheck()
	{
		$link = @mysql_connect(DB_SERVER . ':' . DB_PORT, DB_USER, DB_PASS);
		if (false === $link)
		{
			return false;
		}
		
		$status = @mysql_select_db(DB_NAME, $link);
		if (false === $status)
		{
			return false;
		}
		
		return true;
	}
	
	if (dbCheck())
	{
		echo('Successfully connected to the database');	
	}
	else
	{
		echo('Error connecting to the database');
	}
?>