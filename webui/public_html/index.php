<?php
	require_once(dirname(__FILE__) . '/../constants.php');
	require_once(dirname(__FILE__) . '/../common.php');
	require_once(dirname(__FILE__) . '/../multilanguage.php');
	require_once(dirname(__FILE__) . '/../idna_convert.class.php');
	require_once(dirname(__FILE__) . '/../stripslashes.php');

	// Get language
	$languageId = DEFAULT_LANGUAGE_ID;
	if ((isset($_GET['lang'])) && (isset($translationMap[$_GET['lang']])))
	{
		$languageId = $_GET['lang'];
	}

	// Get test type
	$test = 'standard';
	if(isset($_GET['test']))
	{
		switch($_GET['test'])
		{
			case 'undelegated':
				$test = 'undelegated';
				break;
			default:
				$test = 'standard';
		}
	}

	$permalinkId = 0;
	$permalinkView = 0;
	$permalinkDomain = '';
	if ((isset($_GET['id'])) && (isset($_GET['time'])) && (isset($_GET['view'])) && (in_array($_GET['view'], array('basic', 'advanced'))))
	{
		$testId = intval($_GET['id']);
		$testTime = intval($_GET['time']);

		$query = "SELECT id, domain FROM tests WHERE id = $testId AND UNIX_TIMESTAMP(begin) = $testTime";
		$result = null;
		$status = DatabasePackage::query($query, $result);
		if ((true === $status) && (1 == count($result)))
		{
			$permalinkId = intval($result[0]['id']);

			$IDN = new idna_convert();
			$permalinkDomain = $IDN->decode($result[0]['domain']);

			$permalinkView = (('basic' == $_GET['view']) ? 1 : 2);
		}
	}

	$test = 'standard';
	if(isset($_GET['test']))
	{
		switch($_GET['test'])
		{
			case 'undelegated':
				$test = 'undelegated';
				break;
			default:
				$test = 'standard';
		}
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<script type="text/javascript" src="_js/jquery-1.2.2.min.js?20090218_1622"></script>
<script type="text/javascript" src="_js/DNSCheck.js?20090218_1622"></script>
<script type="text/javascript">
	var domainDoesNotExistHeader = "<?php echo(translate("Domain doesn't exist"));?>";
	var domainDoesNotExistLabel = "<?php echo(translate("The domain you entered doesn't seem to be registered"));?>";
	var domainSyntaxHeader = "<?php echo(translate("Domain syntax"));?>";
	var domainSyntaxLabel = "<?php echo(translate("Invalid domain syntax"));?>";
	var noNameserversHeader = "<?php echo(translate("Nameservers error"));?>";
	var noNameserversLabel = "<?php echo(translate("At least one nameserver should be entered"));?>";
	var loadingHeader = "<?php echo(translate("Loading"));?>";
	var loadingLabel = "<?php echo(translate("Waiting for the test results to be loaded"));?>";
	var loadErrorHeader = "<?php echo(translate("Connection error"));?>";
	var loadErrorLabel = "<?php echo(translate("Could not connect to main database, try again later"));?>";
	var okHeader = "<?php echo(translate("All tests are ok"));?>";
	var warningHeader = "<?php echo(translate("Warnings found in test"));?>";
	var errorHeader = "<?php echo(translate("Errors found in test"));?>";
	var languageId = "<?php echo($languageId)?>";
	var permalinkId = <?php echo((0 < $permalinkId) ? $permalinkId : 'null');?>;
	var permalinkView = <?php echo($permalinkView)?>;
	var test = '<?php echo($test);?>';
	var guiTimeout = <?php echo(GUI_TIMEOUT);?>;
</script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>DNSCheck</title>
<link href="_css/dnscheck.css?20090218_1622" rel="stylesheet" type="text/css" />
</head>

<body>

<div id="wrapper">
	<input type="hidden" value="<?php echo ($test);?>" id="test_type"/>
	<div id="top">
		<h1 id="logo_dnscheck"><a href="#dnscheck">DNSCheck</a></h1>
		<h2 id="logo_se"><a href="#se"><?php echo(translate("A service from .SE"));?></a></h2>
        <div class="clear"> </div>
			<div id="searchbox">
            	<div class="testtabs">
                <ul>
               	  <li <?php if($test == 'standard'): ?>class="testtabson"<?php endif; ?>><a href="<?php echo("?lang=" . $languageId);?>"><?php echo(translate("Domain test"));?></a></li>
                  <li <?php if($test == 'undelegated'): ?>class="testtabson"<?php endif; ?>><a href="<?php echo("?lang=" . $languageId . "&test=undelegated");?>"><?php echo(translate("Undelegated domain test"));?></a></li>
                </ul>
                </div>
				<h3 id="searchhead"><?php echo(translate("Test your DNS-server and find errors"));?></h3>

				<form id="mainform" action="">
                <div id="testinput">
                        <label for="domaininput"><?php echo(translate("Domain name"));?>:</label>
                        <input name="" type="text" id="domaininput" value="<?php echo($permalinkDomain);?>" />
    			</div>
    		<?php if($test != 'undelegated'):?>
                <p id="testtext"><?php echo(translate("Enter your domain name in the field below to test the DNS-servers that are used."));?></p>
            <?php else:?>
            	<p id="testtext"><?php echo(translate("Enter your undelegated domain name in the field above and the hostname(s) and IP(s) to the name servers you want to test below. You can add up to 30 name servers."));?></p>
           	<?php endif;?>

			<?php if($test == 'undelegated'):?>
				<div id="nameservers">
	              	<h4 class="tabhead"><span><?php echo(translate("Name servers"));?></span></h4>
	              	<div class="nameserver" id="nameserver">
	                	<label for="nameserver_host"><?php echo(translate("Host"));?>:</label>
	                    <input name="nameserver_host" type="text"/>
	                	<label for="nameserver_ip"><?php echo(translate("IP"));?>:</label>
	                    <input name="nameserver_ip" type="text" />
	                    <a href="#" title="<?php echo(translate("Remove name server"));?>" class="removenameserver"><img src="_img/icon_remove.png" width="18" height="18" style="border:none" alt="<?php echo(translate("Remove name server"));?>" /></a>
	              	</div>
              	</div>
              	<p class="addnameserver">
					<a id="addnameserver" href="#"><?php echo(translate("Add name server"));?></a>
				</p>
              <?php endif;?>

              <p id="testbutton"><a href="javascript:void(0);" id="testnow" class="button"><?php echo(translate("Test now"));?></a></p>

				</form>
			</div>

			<div id="menu">
				<ul>
					<li><a href="./<?php echo("?lang=" . $languageId . "&test=" . $test); ?>"><?php echo(translate("Home")); ?></a></li>
					<li><a href="./?faq=1<?php echo("&lang=" . $languageId . "&test=" . $test); ?>"><?php echo(translate("FAQ")); ?></a></li>
				</ul>
			</div>
            <div class="clear"> </div>
	</div>

	<div id="startwrapper">
		<?php if (isset($_GET['faq']) && ("1" == $_GET['faq'])) { ?>
			<h3><?php echo(translate("DNSCheck FAQ")); ?></h3>
			<div class="startbox">
			<?php echo(translate("DNSCheck FAQ contents"));?>
			</div>
		<?php } else { ?>
			<h3><?php echo(translate("About DNSCheck"));?></h3>
			<div class="startbox">
			<?php echo(translate("DNSCheck info"));?>
			<h5><?php echo(translate("About DNS"));?></h5>
			<?php echo(translate("DNS info"));?>
			</div>
		<?php } ?>
	</div>

	<div id="result_status" style="display:none">
		<div id="status_light" class="mainload">&nbsp;</div>
		<h3 id="status_header"></h3>
		<p id="status_text"></p>
		<div id="status_bottom"> </div>
	</div>

	<?php if($test == 'undelegated'):?>
	    <div id="undelegateddomain_info" style="display:none">
	    <p><strong><?php echo(translate("Note"));?>:</strong> <?php echo(translate("This test was performed on a undelegated domain"));?></p>
	    </div>
    <?php endif;?>

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
			<span style="display: none" id="link_to_test_label"><?php echo(translate("Link to this test")); ?>:</span>
		</div>
		<div id="history">
			<h3 class="smalltop"><img src="_img/mini-loader.gif" style="display: none" id="history_loader" alt="Loading" width="16" height="16" /><?php echo(translate("Test history"));?></h3>
			<div class="smallbox">
			<p id="pager_error" style="display: none"><img src="_img/icon_warning.gif" alt="Error" width="16" height="14" /> <?php echo(translate("Error loading history"));?></p>
			<p id="pager_no_history" style="display: none"><?php echo(translate("No test history found"));?></p>
			<ul id="pagerlist">
				<li style="display:none"><?php echo(translate("Test history"));?></li>
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

			<h3 class="smalltop topmargin"><?php echo(translate("Explanation"));?></h3>
			<div class="smallbox">
				<p class="testok"><?php echo(translate("Test was ok"));?></p>
				<p class="testwarn"><?php echo(translate("Test contains warnings"));?></p>
				<p class="testerror"><?php echo(translate("Test contains errors"));?></p>
				<p class="testoff"><?php echo(translate("Test was not performed"));?></p>
			</div>

		</div>
	</div>

	<div id="footer">
		<p id="f_info"><?php echo(translate(".SE (The Internet Infrastructure Foundation)"));?></p>
		<?php if('en' != $languageId){?><p id="f_links"><a href="?lang=en&test=<?php echo $test;?>" class="lang_en">English version</a><br /></p><?php }?>
		<?php if('se' != $languageId){?><p id="f_links"><a href="?lang=se&test=<?php echo $test;?>" class="lang_se">Swedish version</a><br /></p><?php }?>
		<br class="clear" />
	</div>

</div>

</body>
</html>
