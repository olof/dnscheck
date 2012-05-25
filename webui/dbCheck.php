<?php
	require_once('config.php');

	function dbCheck()
	{
		$link = @mysql_connect($conf['db_server'] . ':' . $conf['db_port'], $conf['db_user'], $conf['db_pass']);
		if (false === $link)
		{
			return false;
		}
		
		$status = @mysql_select_db($conf['db_name'], $link);
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