<?php
	require_once('constants.php');
	require_once('multilanguage.php');
	
	$languageId = DEFAULT_LANGUAGE_ID;
	if ((isset($_GET['lang'])) && (isset($translationMap[$_GET['lang']])))
	{
		$languageId = $_GET['lang'];
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<script type="text/javascript" src="_js/jquery-1.2.2.min.js"></script>
<script type="text/javascript" src="_js/DNSCheck.js?20080218_1622"></script>
<script>
	var domainDoesNotExistHeader = "<?php echo(translate("Domain doesn't exist"));?>";
	var domainDoesNotExistLabel = "<?php echo(translate("The domain you entered doesn't seem to be registered"));?>";
	var loadingHeader = "<?php echo(translate("Loading"));?>";
	var loadingLabel = "<?php echo(translate("Waiting for the test results to be loaded"));?>";
	var okHeader = "<?php echo(translate("All tests are ok"));?>";
	var warningHeader = "<?php echo(translate("Warnings found in test"));?>";
	var errorHeader = "<?php echo(translate("Errors found in test"));?>";
	var languageId = "<?php echo($languageId)?>";
</script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>DNSCheck</title>
<link href="_css/dnscheck.css" rel="stylesheet" type="text/css" />
</head>

<body>

<div id="wrapper">

	<div id="top">
		<h1 id="logo_dnscheck"><a href="#dnscheck">DNSCheck</a></h1>
		<h2 id="logo_se"><a href="#se"><?php echo(translate("A service from .SE"));?></a></h2>
			<div id="searchbox">
				<h3 id="searchhead"><?php echo(translate("Test your DNS-server and find errors"));?></h3>
				<p><?php echo(translate("Enter your domain name in the field below to test the DNS-servers that are used."));?></p>
				<form id="mainform">
					<input name="" type="text" id="domaininput" />
					<a href="javascript:void(0);" id="testnow" class="button"><?php echo(translate("Test now"));?></a>
				</form>
			</div>
	</div>

	<div id="startwrapper">
		<h3><?php echo(translate("About DNSCheck"));?></h3>
		<div class="startbox">
		<?php echo(translate("DNSCheck info"));?>
		<h5><?php echo(translate("About DNS"));?></h5>
		<?php echo(translate("DNS info"));?>
		</div>
	</div>
	
	<div id="result_status" style="display:none">
		<div id="status_light" class="mainload">&nbsp;</div>
		<h3 id="status_header"></h3>
		<p id="status_text"></p>
	</div>
	

	<div id="resultwrapper" style="display:none">
		<div id="result">
			<div class="widetop">
				<img src="_img/mini-loader.gif" style="display: none" id="result_loader" alt="Loading" width="16" height="16" />
				<ul class="tabs">
					<li class="tab_on" id="simpletab"><a href="javascript:activateSimpleTab();"><?php echo(translate("Basic results"));?></a></li>
					<li id="advancedtab"><a href="javascript:activateAdvancedTab();"><?php echo(translate("Advanced results"));?></a></li>
				</ul>
			</div>
			<div id="treediv"></div>
			<div id="listdiv" style="display: none"></div>
		</div>
		<div id="history">
			<h3 class="smalltop"><img src="_img/mini-loader.gif" style="display: none" id="history_loader" alt="Loading" width="16" height="16" /><?php echo(translate("Test history"));?></h3>
			<div class="smallbox">
			<p id="pager_error" style="display: none"><img src="_img/icon_warning.gif" alt="Error" width="16" height="14" /> <?php echo(translate("Error loading history"));?></p>
			<p id="pager_no_history" style="display: none"><?php echo(translate("No test history exist"));?></p>
			<ul id="pagerlist">
			</ul>
			</div>
			<div class="pager" id="pagerbuttonsdiv">
			<a href="javascript:void(0);"><img src="_img/pager_start_off.png" alt="Start" id="pagerstart" /></a>
			<a href="javascript:void(0);"><img src="_img/pager_back_off.png" alt="Back" id="pagerback" /></a>
			<p><?php echo(translate("Page"));?> <span id="pagerlabel"></span></p>
			<a href="javascript:void(0);"><img src="_img/pager_forward_on.png" alt="Forward" id="pagerforward" /></a>
			<a href="javascript:void(0);"><img src="_img/pager_end_on.png" alt="End" id="pagerend" /></a>
			<div class="clear"> </div>
			</div>
		</div>	
	</div>

	<div id="footer">
		<p id="f_info"><?php echo(translate(".SE (The Internet Infrastructure Foundation)"));?></p>
		<?php if('en' != $languageId){?><p id="f_links"><a href="?lang=en" class="lang_en">English version</a><br /></p><?php }?>
		<?php if('se' != $languageId){?><p id="f_links"><a href="?lang=se" class="lang_se">Swedish version</a><br /></p><?php }?>
		<br class="clear" />
	</div>

</div>

</body>
</html>
