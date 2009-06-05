<?php
	require_once('constants.php');

	function checkIfDomainExists($domain, $testType)
	{
		$command = "";
		if($testType == "undelegated"){
			$command = "dnscheck-hostsyntax '" . addslashes($domain) . "'";
		}
		else{
			$command = "dnscheck-preflight '" . addslashes($domain) . "'";
		}
		$commandOutput = array();
		$commandReturnValue = null;
		@exec($command, $commandOutput, $commandReturnValue);

		$rawOutput = implode("\r\n", $commandOutput) . "\r\n";

		if (false === strpos($rawOutput, 'TRUE'))
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	/**
	 * Gets source ID. It checks if ID is already there, and if it is not, it creates one and returns it.
	 * @param $source String identifier of the source
	 * @return int Id of the source. -1 If database query failed.
	 */
	function getSourceID($source)
	{
		$result;

		// 	Get the value
		$query = "SELECT id FROM source WHERE name = '" . DatabasePackage::escape($source). "'";
		$status = DatabasePackage::query($query, $result);
		if (true !== $status)
		{
			return -1;
		}

		if(count($result) == 0)
		{
			// Make a new insert, if we do not have the result
			$query = "INSERT IGNORE INTO source (name) VALUES ('" . DatabasePackage::escape($source) . "')";
			$status = DatabasePackage::query($query, $result);
			if (true !== $status)
			{
				return -1;
			}

			// Get the value
			$query = "SELECT id FROM source WHERE name = '" . DatabasePackage::escape($source). "'";
			$status = DatabasePackage::query($query, $result);
			if (true !== $status)
			{
				return -1;
			}
		}

		if(count($result) <= 0)
		{
			return -1;
		}

		return intval($result[0]['id']);
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

			$rawResult = @mysql_query($query, self::$dbConnection);
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
