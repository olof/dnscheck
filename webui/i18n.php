<?php

require_once("constants.php");

// Autoloader for autoload classes (PHP5 standard)
function autoloader($class) {
    require "lib/" . str_replace('_', '/', $class) . '.php';
}
spl_autoload_register('autoloader');

function i18n_get_language_names() {
	// Check for existing cookie with names
	
	if ($_COOKIE["i18n_language_names"]) {
		return unserialize($_COOKIE["i18n_language_names"]);
	}
	
	// No cookie, get language names from files
	// Create an array to hold directory list
    $langAr = array();

    // Create a handler for the directory
    $dir = opendir("../languages/");

    // Loop through files in directory
    while ($file = readdir($dir)) {

        // if $file isn't this directory or its parent, 
        // check if it ends in .yaml and if it does, read in "languageName"
        // then add it to the results array
        if ($file != '.' && $file != '..') {
        	if (substr($file, (strlen($file) - 4)) == "yaml") {
        		$thisLanguage = Horde_Yaml::loadFile("../languages/$file");
        		$langAr[$thisLanguage["languageId"]] = $thisLanguage["languageName"];
        	}
        }
    }

    // tidy up: close the handler
    closedir($dir);

	// Set cookie
	setcookie("i18n_language_names", serialize($langAr));
	return ($langAr);
}


/**
 * Load language file
 *
 * @param string $language - if left empty loads saved language selection (from cookie) or default language
 * @return bool success
 */
function i18n_load_language($language = NULL) {
	global $i18n_lang, $i18n_current_language;
	
	if ($language == NULL) {
		$language = $_COOKIE["i18n_language"];
		if (!$language) {
			$language = getDefaultLanguage();
		}
	}
	
	$i18n_current_language = $language;
		
	if ($i18n_lang = Horde_Yaml::loadFile("../languages/$language.yaml")) {
		return true;
	}
	else {
		return false;	
	}
}


/**
 * Return language string for given key
 *
 * @param string $key
 * @param string $language - optional. If $language is not specified, use the currently loaded language.
 */
function __($key, $file = false, $language = NULL) {
	global $i18n_lang, $i18n_current_language;

	if (!is_array($i18n_lang)) {
		// No language loaded? Load language now!
		i18n_load_language($language);	
	}
	
	if ($file == true) {
		// Instead of language YAML file, get requested file.
		// Files to output should be in the languages/ folder and be named $language_$file.html
		// I.e. a call to _e("faq", true) will look for the file "languages/english_faq.html" if the current language is english.
		return file_get_contents("../languages/$i18n_current_language" . "_" . "$key.html");
	}
	
	
	if ($language == NULL) {
		if ($i18n_lang[$key]) {
			return $i18n_lang[$key];	
		}
	}
	else {
		// Language is specified, switch language now!
		i18n_load_language($language);
		return $i18n_lang[$key];	
	}
	
}

/**
 * Echo language string for given key
 *
 * @param string $key
 * @param string $language - optional. If $language is not specified, use the currently loaded language.
 */
function _e($key, $file = false, $language = NULL) {
	echo __($key, $file, $language);
}



?>