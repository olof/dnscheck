<?php
		$command = "dig 'iis.se'";
		$commandOutput = array();
		$commandReturnValue = null;
		@exec($command, $commandOutput, $commandReturnValue);
		
		$rawOutput = implode("\r\n", $commandOutput) . "\r\n";
		
		echo("<pre>");
		echo($rawOutput);
		echo("</pre>");
?>