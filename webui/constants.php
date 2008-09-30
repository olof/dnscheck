<!-- $Id$ -->

<?php
	require_once('IP2Country.php');

	define('DB_SERVER', 'localhost');
	define('DB_PORT', 3306);
	define('DB_NAME', 'dnscheckng');
	define('DB_USER', 'dnscheckng');
	define('DB_PASS', 'engine');

	define('STATUS_OK', 'OK');
	define('STATUS_WARN', 'WARNING');
	define('STATUS_ERROR', 'ERROR');
	define('STATUS_DOMAIN_DOES_NOT_EXIST', 'ERROR_DOMAIN_DOES_NOT_EXIST');
	define('STATUS_IN_PROGRESS', 'IN_PROGRESS');
	define('STATUS_INTERNAL_ERROR', 'INTERNAL_ERROR');

	define('PAGER_SIZE', 10);
	
	$supportedLanguages = array(
		array(
			'id' => 'en',
			'caption' => 'English language',
			'active' => true
		),
		array(
			'id' => 'se',
			'caption' => 'Swedish version',
			'active' => false
		)
	);
	
	define('DEFAULT_LANGUAGE_ID', getDefaultLanguage());
?>
