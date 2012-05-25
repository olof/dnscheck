<?php
	require_once('IP2Country.php');

	$conf = array(
	    'db_server' => 'localhost',
	    'db_port' => 3306,
	    'db_name' => 'dnscheck',
	    'db_user' => 'dnscheck_webui',
	    'db_pass' => 'n5k4nbfnfn',
	);

	define('STATUS_OK', 'OK');
	define('STATUS_WARN', 'WARNING');
	define('STATUS_ERROR', 'ERROR');
	define('STATUS_DOMAIN_DOES_NOT_EXIST', 'ERROR_DOMAIN_DOES_NOT_EXIST');
	define('STATUS_DOMAIN_SYNTAX', 'ERROR_DOMAIN_SYNTAX');
	define('STATUS_NO_NAMESERVERS', 'ERROR_NO_NAMESERVERS');
	define('STATUS_IN_PROGRESS', 'IN_PROGRESS');
	define('STATUS_INTERNAL_ERROR', 'INTERNAL_ERROR');

	define('PAGER_SIZE', 10);
	
	define('GUI_TIMEOUT', 300);

	$sourceIdentifiers = array(
		'standard' => 'webgui',
		'undelegated' => 'webgui-undelegated'
	);


	define('DEFAULT_LANGUAGE_ID', getDefaultLanguage());

	/* Provide a place where settings can be overridden, to make Debian packaging easier. */
	if (is_readable('/etc/dnscheck/webui_config.php')) {
		require_once('/etc/dnscheck/webui_config.php');
	}

?>
