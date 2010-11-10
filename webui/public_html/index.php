<?php
require_once(dirname(__FILE__) . '/../constants.php');
require_once(dirname(__FILE__) . '/../common.php');
require_once(dirname(__FILE__) . '/../i18n.php');
require_once(dirname(__FILE__) . '/../idna_convert.class.php');
require_once(dirname(__FILE__) . '/../stripslashes.php');

i18n_get_language_names();

function filter_lang($lang)
{
	if ( 0 == preg_match('/^[a-z][a-z]$/',$lang))
	{
		$lang = "en";
	}

	return $lang;
}

// Set language
if (isset($_GET["setLanguage"])) {
	i18n_load_language(filter_lang($_GET["setLanguage"]));
	setcookie("i18n_language", filter_lang($_GET["setLanguage"]));
}
else {
	// Language should be based on cookie or default
	if (isset($_COOKIE["i18n_language"])) {
		i18n_load_language(filter_lang($_COOKIE["i18n_language"]));	
	}
	else {
		// Default language 
		i18n_load_language();
	}
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

// Get current version of DNSCheck by checking last made test
$sql = "SELECT arg1 FROM results WHERE message = 'ZONE:BEGIN' and test_id = (select max(test_id) from results) ORDER BY test_id DESC LIMIT 0, 1";
$status = DatabasePackage::query($sql, $version);
$thisVersion = $version[0]["arg1"];

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<script type="text/javascript" src="_js/jquery-1.2.2.min.js?20090217_1622"></script>
<script type="text/javascript" src="_js/DNSCheck.js?20090217_1622"></script>
<script type="text/javascript">
var domainDoesNotExistHeader = "<?php _e("domain_doesnt_exist_header");?>";
var domainDoesNotExistLabel = "<?php _e("domain_doesnt_exist_label");?>";
var domainSyntaxHeader = "<?php _e("domain_syntax_header");?>";
var domainSyntaxLabel = "<?php _e("domain_syntax_label");?>";
var noNameserversHeader = "<?php _e("nons_header");?>";
var noNameserversLabel = "<?php _e("nons_label");?>";
var loadingHeader = "<?php _e("loading_header");?>";
var loadingLabel = "<?php _e("loading_label");?>";
var loadErrorHeader = "<?php _e("load_error_header");?>";
var loadErrorLabel = "<?php _e("load_error_label");?>";
var okHeader = "<?php _e("all_tests_ok");?>";
var warningHeader = "<?php _e("warning_header");?>";
var errorHeader = "<?php _e("error_header");?>";
<?php print ($languageId ? "var languageId = \"$languageId\";\n" : ""); ?>
var languageId = "<?php echo($languageId)?>";
var permalinkId = <?php echo((0 < $permalinkId) ? $permalinkId : 'null');?>;
var permalinkView = <?php echo($permalinkView)?>;
var test = '<?php echo($test);?>';
var guiTimeout = <?php echo(GUI_TIMEOUT);?>;
var thisId = 0;
var thisTime = 0;
var thisVersion = "<?php echo $thisVersion; ?>";
var labelVersion = "<?php _e("test_was_performed_with_version"); ?>";

function switchLang(lang) {
	//alert(document.thisId + ":" + document.thisTime);
	document.location.href='?time=' + document.thisTime + '&id=' + document.thisId + '&test=<?php echo $test?>&view=<?php print($_GET["view"]!="advanced" ? "basic" : "advanced" );?>&setLanguage=' + lang;	
}

</script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>DNSCheck</title>
<link href="_css/dnscheck.css?20090217_1622" rel="stylesheet" type="text/css" />
</head>

<body>
<div id="wrapper">
	<input type="hidden" value="<?php echo ($test);?>" id="test_type"/>
	<div id="top">
		<h1 id="logo_dnscheck"><a href="#dnscheck">DNSCheck</a></h1>
		<h2 id="logo_se"><a href="#se"><?php _e("a_service_from_se");?></a></h2>
        <div class="clear"> </div>
			<div id="searchbox">
            	<div class="testtabs">
                <ul>
               	  <li <?php if($test == 'standard'): ?>class="testtabson"<?php endif; ?>><a href="./"><?php _e("domain_test");?></a></li>
                  <li <?php if($test == 'undelegated'): ?>class="testtabson"<?php endif; ?>><a href="?test=undelegated"><?php _e("undelegated_domain_test");?></a></li>
                </ul>
                </div>
				<h3 id="searchhead"><?php _e("test_and_find_errors");?></h3>

				<form id="mainform" action="">
                <div id="testinput">
                        <label for="domaininput"><?php _e("domain_name");?>:</label>
                        <input name="" type="text" id="domaininput" value="<?php echo($permalinkDomain);?>" />
    			</div>
    		<?php if($test != 'undelegated'):?>
                <p id="testtext"><?php _e("enter_your_domain_name");?></p>
            <?php else:?>
            	<p id="testtext"><?php _e("enter_your_undelegated_domain_name");?>
            	<a href="./?faq=1&test=undelegated#f16"><?php _e("what_is_an_undelegated");?></a>
            	</p>
            	
           	<?php endif;?>

			<?php if($test == 'undelegated'):?>
				<div id="nameservers">
	              	<h4 class="tabhead"><span><?php _e("name_servers");?></span></h4>
	              	<div class="nameserver" id="nameserver">
	                	<label for="nameserver_host"><?php _e("host");?>:</label>
	                    <input name="nameserver_host" type="text"/>
	                	<label for="nameserver_ip"><?php _e("ip");?>:</label>
	                    <input name="nameserver_ip" type="text" />
	                    <a href="#" title="<?php _e("remove_name_server");?>" class="removenameserver"><img src="_img/icon_remove.png" width="18" height="18" style="border:none" alt="<?php _e("remove_name_server");?>" /></a>
	              	</div>
              	</div>
              	<p class="addnameserver">
					<a id="addnameserver" href="#"><span><?php _e("add_name_server");?></span></a>
				</p><br class="clear" />
              <?php endif;?>

              <p id="testbutton"><a href="javascript:void(0);" id="testnow" class="button"><?php _e("test_now");?></a></p>

				</form>
			</div>

			<div id="menu">
				<ul>
					<li><a href="./?test=<?php echo $test; ?>"><?php _e("home"); ?></a></li>
					<li><a href="./?faq=1&amp;test=<?php echo $test; ?>"><?php _e("faq"); ?></a></li>
				</ul>
			</div>
            <div class="clear"> </div>
	</div>

	<div id="startwrapper">
		<?php if (isset($_GET['faq']) && ("1" == $_GET['faq'])) { ?>
			<h3><?php _e("faq"); ?></h3>
			<div class="startbox">
			<?php _e("faq", true);?>
			</div>
		<?php } else { ?>
			<h3><?php _e("about_dnscheck");?></h3>
			<div class="startbox">
			<?php _e("about", true);?>
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
	    <p><strong><?php _e("note");?>:</strong> <?php _e("this_test_on_undelegated");?></p>
	    </div>
    <?php endif;?>

	<div id="resultwrapper" style="display:none">
		<div id="result">
			<div class="widetop">
				<img src="_img/mini-loader.gif" style="display: none" id="result_loader" alt="Loading" width="16" height="16" />
				<ul class="tabs">
					<li class="tab_on" id="simpletab"><a href="javascript:activateSimpleTab();"><?php _e("basic_results");?></a></li>
					<li id="advancedtab"><a href="javascript:activateAdvancedTab();"><?php _e("advanced_results");?></a></li>
				</ul>
			</div>
			<div id="treediv"></div>
			<div id="listdiv" style="display: none"></div>
			<span style="display: none" id="link_to_test_label"><?php _e("link_to_this_test"); ?>:</span>
		</div>
		<div id="history">
			<h3 class="smalltop"><img src="_img/mini-loader.gif" style="display: none" id="history_loader" alt="Loading" width="16" height="16" /><?php _e("test_history");?></h3>
			<div class="smallbox">
			<p id="pager_error" style="display: none"><img src="_img/icon_warning.gif" alt="Error" width="16" height="14" /> <?php _e("error_loading_history");?></p>
			<p id="pager_no_history" style="display: none"><?php _e("no_test_history");?></p>
			<ul id="pagerlist">
				<li style="display:none"><?php _e("test_history");?></li>
			</ul>
			</div>
			<div class="pager" id="pagerbuttonsdiv">
			<a href="javascript:void(0);"><img src="_img/pager_start_off.png" alt="Start" id="pagerstart" /></a>
			<a href="javascript:void(0);"><img src="_img/pager_back_off.png" alt="Back" id="pagerback" /></a>
			<p><?php _e("page"); ?> <span id="pagerlabel"></span></p>
			<a href="javascript:void(0);"><img src="_img/pager_forward_on.png" alt="Forward" id="pagerforward" /></a>
			<a href="javascript:void(0);"><img src="_img/pager_end_on.png" alt="End" id="pagerend" /></a>
			<div class="clear"> </div>
			</div>

			<h3 class="smalltop topmargin"><?php _e("explanation"); ?></h3>
			<div class="smallbox">
				<p class="testok"><?php _e("test_was_ok");?></p>
				<p class="testwarn"><?php _e("test_contains_warnings");?></p>
				<p class="testerror"><?php _e("test_contains_errors");?></p>
				<p class="testoff"><?php _e("test_was_not_performed");?></p>
			</div>

		</div>
	</div>

	<div id="footer">
		<p id="f_info"><?php 
		$footer = __("se_tagline");
		$sql = "SELECT arg1 FROM results WHERE message = 'ZONE:BEGIN' and test_id = (select max(test_id) from results) ORDER BY test_id DESC LIMIT 0, 1";
		$status = DatabasePackage::query($sql, $version);
		printf($footer, $version[0]["arg1"], $_SERVER["REMOTE_ADDR"]);
		
		?>
		</p>
		
		<p id="f_links"><?php _e("language");?>: 
		
			<select name="language" onchange="switchLang(this[this.selectedIndex].value);">
<?php

			$langAr = i18n_get_language_names();
			
			foreach($langAr AS $key => $name) {
				echo "				<option ";
						if (strtolower($i18n_current_language) == strtolower($key)) {
							echo "SELECTED ";	
						}
				echo "value=\"$key\">$name</option>\n";
			}
			
			?>
			</select>
		</p>
		<br class="clear" />
	</div>

</div>

</body>
</html>
