<?php
	require_once('constants.php');
	
	function checkIfDomainExists($domain)
	{
		if (".se" == substr($domain, -3))
		{
			$query = "SELECT domains.domain FROM domains WHERE domains.domain = '" . DatabasePackage::escape($domain) . "'";
			$result = null;
			$status = DatabasePackage::query($query, $result);
			if (true !== $status)
			{
				return false;
			}
			
			return (0 < count($result));
		}
		
		$command = "dig '" . addslashes($domain) . "'";
		$commandOutput = array();
		$commandReturnValue = null;
		@exec($command, $commandOutput, $commandReturnValue);
		
		$rawOutput = implode("\r\n", $commandOutput) . "\r\n";
		
		return (false !== strpos($rawOutput, 'ANSWER SECTION'));
	}

	class DatabasePackage
	{
		private static $dbConnection = null;
		
		private static function connect()
		{
			if (!is_null($dbConnection))
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