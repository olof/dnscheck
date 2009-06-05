<?php

require_once("constants.php");

// Autoloader for autoload classes (PHP5 standard)
function autoloader($class) {
    require "lib/" . str_replace('_', '/', $class) . '.php';
}
spl_autoload_register('autoloader');

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