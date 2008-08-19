<?php
	require_once('constants.php');
	
	function checkIfDomainExists($domain)
	{
		$command = "dig +nssearch '" . addslashes($domain) . "'";
		$commandOutput = array();
		$commandReturnValue = null;
		@exec($command, $commandOutput, $commandReturnValue);
		
		$rawOutput = implode("\r\n", $commandOutput) . "\r\n";
		
		if (false === strpos($rawOutput, 'SOA'))
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	class DatabasePackage
	{
		private static $dbConnection = null;
		
		private static function connect()
		{
			if (!is_null(self::$dbConnection))
			{
				return true;	
			}
			
			$link = mysql_connect(DB_SERVER . ':' . DB_PORT, DB_USER, DB_PASS);
			if (false === $link)
			{
				return false;
			}
			
			$status = mysql_select_db(DB_NAME, $link);
			if (false === $status)
			{
				return false;
			}
			
			self::$dbConnection = $link;
			
			return true;
		}
		
		public static function query($query, &$result)
		{
			$status = self::connect();
			if (false === $status)
			{
				return false;
			}
			
			$rawResult = mysql_query($query, self::$dbConnection);
			if (false === $rawResult)
			{
				return false;	
			}
			
			$result = array();
			if (true !== $rawResult)
			{
				while ($row = mysql_fetch_assoc($rawResult))
				{
					$result[] = $row;
				}
			}
			
			return true;
		}
		
		public static function escape($string)
		{
			$status = self::connect();
			if (false === $status)
			{
				return false;
			}
			
			return mysql_real_escape_string($string, self::$dbConnection);
		}
	}
?>
