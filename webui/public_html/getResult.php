<?php
require_once(dirname(__FILE__) . '/../constants.php');
require_once(dirname(__FILE__) . '/../common.php');
require_once(dirname(__FILE__) . '/../idna_convert.class.php');
require_once(dirname(__FILE__) . '/../stripslashes.php');
require_once(dirname(__FILE__) . '/../i18n.php');

function flattenTree($rootNode, $type, $allMessages, &$flattenedTree)
{
	$status = 'ok';
	$flattenedTree = array();
	$IDN = new idna_convert();
	foreach ($rootNode as $treeNode)
	{
		if (!isset($treeNode['message']))
		{
			$flattenedSubtree = null;
			$result = flattenTree($treeNode, $type, $allMessages, $flattenedSubtree);
			foreach ($flattenedSubtree as $subtreeNode)
			{
				$flattenedTree[] = $subtreeNode;
				if (('warn' == $result) && ('ok' == $status))
				{
					$status = 'warn';
				}
				elseif ('error' == $result)
				{
					$status = 'error';
				}
			}
		}
		elseif (('WARNING' == $treeNode['level']) || ('ERROR' == $treeNode['level']) || ((('INFO' == $treeNode['level']) || ('NOTICE' == $treeNode['level'])) && ($allMessages)))
		{
			if (is_null($treeNode['formatstring']))
			{
				$caption = "-";
			}
			else
			{
				$caption = sprintf($treeNode['formatstring'], $IDN->decode($treeNode['arg0']), $IDN->decode($treeNode['arg1']), $IDN->decode($treeNode['arg2']), $IDN->decode($treeNode['arg3']),
				$IDN->decode($treeNode['arg4']), $IDN->decode($treeNode['arg5']), $IDN->decode($treeNode['arg6']), $IDN->decode($treeNode['arg7']), $IDN->decode($treeNode['arg8']), $IDN->decode($treeNode['arg9']));
			}

			$className = '';
			switch ($treeNode['level'])
			{
				case 'WARNING':
					$className = 'warn';
					break;
				case 'ERROR':
					$className = 'error';
					break;
				case 'NOTICE':
					$className = 'notice';
					break;
			}

			$flattenedTreeItem = array('type' => $type, 'class' => $className, 'caption' => $caption, 'subtree' => array());
			if (!is_null($treeNode['description']))
			{
				$flattenedTreeItem['description'] = $treeNode['description'];
			}
			$flattenedTree[] = $flattenedTreeItem;
			if (('WARNING' == $treeNode['level']) && ('ok' == $status))
			{
				$status = 'warn';
			}
			elseif ('ERROR' == $treeNode['level'])
			{
				$status = 'error';
			}
		}
	}

	return $status;
}

function getRawResultTree($testId, $languageId, &$rawResultTree)
{
	$resultTree = array();
	$moduleReferences = array(0 => &$resultTree);

	$query = "
			SELECT
							*
				FROM
				(
					SELECT
									*
						FROM	results
						WHERE	results.test_id = $testId
								AND results.level != 'DEBUG'
				) AS tmp
					LEFT JOIN messages ON
						tmp.message = messages.tag
						AND messages.language = '" . DatabasePackage::escape($languageId) . "'
				ORDER BY tmp.id ASC
		";

	$result;
	$status = DatabasePackage::query($query, $result);
	if (true !== $status)
	{
		return false;
	}

	foreach($result as $resultItem)
	{
		if (!isset($moduleReferences[intval($resultItem['module_id'])]))
		{
			$moduleReferences[intval($resultItem['module_id'])] = array();
			$moduleReferences[intval($resultItem['parent_module_id'])][] = &$moduleReferences[intval($resultItem['module_id'])];
		}

		$moduleReferences[intval($resultItem['module_id'])][] = $resultItem;
	}

	$rawResultTree = $resultTree;
}

function constructFinalTree($rawResultTree, $allMessages, $showRootStatuses, &$finalTree)
{
	global $thisVersion;
	$initialRootStatus = $showRootStatuses ? 'off' : '';

	$finalTree = array(
	array('type' => 0, 'class' => $initialRootStatus, 'caption' => __("delegation"), 'subtree' => array()),
	array('type' => 0, 'class' => $initialRootStatus, 'caption' => __("nameserver"), 'subtree' => array()),
	array('type' => 0, 'class' => $initialRootStatus, 'caption' => __("consistency"), 'subtree' => array()),
	array('type' => 0, 'class' => $initialRootStatus, 'caption' => __("soa"), 'subtree' => array()),
	array('type' => 0, 'class' => $initialRootStatus, 'caption' => __("connectivity"), 'subtree' => array()),
	array('type' => 0, 'class' => $initialRootStatus, 'caption' => __("dnssec"), 'subtree' => array())
	);

	$finalResult = STATUS_OK;

	foreach ($rawResultTree[0] as $rootNode)
	{

		if (!$thisVersion) {
			$thisVersion = $rootNode["arg1"];
		}

		if (!isset($rootNode['message']))
		{
			$flattenedArray = null;
			switch($rootNode[0]['message'])
			{
				case 'DELEGATION:BEGIN':
					$result = flattenTree($rootNode, 2, $allMessages, $flattenedArray);
					$finalTree[0]['class'] = $showRootStatuses ? $result : '';
					$finalTree[0]['subtree'] = $flattenedArray;
					break;
				case 'NAMESERVER:BEGIN':
					$result = flattenTree($rootNode, 3, $allMessages, $flattenedArray);
					$nameserverNode = array('type' => 1, 'class' => $showRootStatuses ? $result : '', 'caption' => __("nameserver") . ' ' . $rootNode[0]['arg0'], 'subtree' => $flattenedArray);
					$finalTree[1]['subtree'][] = $nameserverNode;

					if ($showRootStatuses)
					{
						if (('ok' == $result) && ('off' == $finalTree[1]['class']))
						{
							$finalTree[1]['class'] = 'ok';
						}
						elseif (('warn' == $result) && ('error' != $finalTree[1]['class']))
						{
							$finalTree[1]['class'] = 'warn';
						}
						elseif ('error' == $result)
						{
							$finalTree[1]['class'] = 'error';
						}
					}
					break;
				case 'CONSISTENCY:BEGIN':
					$result = flattenTree($rootNode, 2, $allMessages, $flattenedArray);
					$finalTree[2]['class'] = $showRootStatuses ? $result : '';
					$finalTree[2]['subtree'] = $flattenedArray;
					break;
				case 'SOA:BEGIN':
					$result = flattenTree($rootNode, 2, $allMessages, $flattenedArray);
					$finalTree[3]['class'] = $showRootStatuses ? $result : '';
					$finalTree[3]['subtree'] = $flattenedArray;
					break;
				case 'CONNECTIVITY:BEGIN':
					$result = flattenTree($rootNode, 2, $allMessages, $flattenedArray);
					$finalTree[4]['class'] = $showRootStatuses ? $result : '';
					$finalTree[4]['subtree'] = $flattenedArray;
					break;
				case 'DNSSEC:BEGIN':
					$result = flattenTree($rootNode, 2, $allMessages, $flattenedArray);

					$skipped = false;
					foreach ($rootNode as $treeNode)
					{
						if (isset($treeNode['message']) && ('DNSSEC:SKIPPED_NO_KEYS' == $treeNode['message']))
						{
							$skipped = true;
						}
					}
					$finalTree[5]['class'] = $showRootStatuses ? ($skipped ? 'off' : $result) : '';
					$finalTree[5]['subtree'] = $flattenedArray;
					break;
			}

			if (('warn' == $result) && (STATUS_OK == $finalResult))
			{
				$finalResult = STATUS_WARN;
			}

			if ('error' == $result)
			{
				$finalResult = STATUS_ERROR;
			}
		}
	}

	return $finalResult;
}

function main(&$tree, &$list)
{
	global $time;
	global $domain;
	global $testId;
	global $languageId;
	global $sourceIdentifiers;
	global $sourceData;
	global $thisVersion;

	$IDN = new idna_convert();
	$domain = $IDN->encode(trim(strtolower($_REQUEST['domain'])));
	$sourceData = isset($_REQUEST['parameters']) ? trim(strtolower($_REQUEST['parameters'])) : '';

	$testId = 0;
	if (isset($_REQUEST['historyId']))
	{
		$testId = intval($_REQUEST['historyId']);
		$query = "SELECT UNIX_TIMESTAMP(tests.begin) AS time,
							source_data AS source_data
					  FROM tests WHERE tests.id = $testId";
		$result = null;
		$status = DatabasePackage::query($query, $result);
		if (true != $status)
		{
			return STATUS_INTERNAL_ERROR;
		}

		$time = intval($result[0]['time']);
		$sourceData = $result[0]['source_data'];
	}
	else
	{
		$query = "
				(
					SELECT
									NULL AS id,
									NULL AS time,
									'NO' AS finished,
									source_data AS source_data
						FROM	queue
							INNER JOIN source ON source.id  = queue.source_id
								AND source.name = '" . DatabasePackage::escape($sourceIdentifiers[$_REQUEST['test']]) . "'
						WHERE	queue.domain = '" . DatabasePackage::escape($domain) . "'
								AND queue.source_data = '" . DatabasePackage::escape($sourceData) . "'
				)
				UNION
				(
					SELECT
									tests.id AS id,
									UNIX_TIMESTAMP(tests.begin) AS time,
									IF(ISNULL(tests.end), 'NO', 'YES') AS finished,
									source_data AS source_data
						FROM	tests
							INNER JOIN source ON source.id  = tests.source_id
								AND source.name = '" . DatabasePackage::escape($sourceIdentifiers[$_REQUEST['test']]) . "'
						WHERE	tests.domain = '" . DatabasePackage::escape($domain) . "'
								AND (ISNULL(tests.end) OR (UNIX_TIMESTAMP() - UNIX_TIMESTAMP(tests.end) < 300))
								AND tests.source_data = '" . DatabasePackage::escape($sourceData) . "'
				)
			";

		$result = null;
		$status = DatabasePackage::query($query, $result);
		if (true != $status)
		{
			return STATUS_INTERNAL_ERROR;
		}

		if (0 == count($result))
		{
			$id = getSourceID($sourceIdentifiers[$_REQUEST['test']]);
			$query = "INSERT INTO queue (domain, priority, source_id, source_data, fake_parent_glue) VALUES ('" . DatabasePackage::escape($domain) . "', 10, $id, '" . DatabasePackage::escape($sourceData) . "', '" . DatabasePackage::escape($sourceData) . "')";
			$result;
			$status = DatabasePackage::query($query, $result);

			if (true !== $status)
			{
				return STATUS_INTERNAL_ERROR;
			}
			return STATUS_IN_PROGRESS;
		}

		if ('NO' == $result[0]['finished'])
		{
			return STATUS_IN_PROGRESS;
		}

		$testId = intval($result[0]['id']);
		$time = intval($result[0]['time']);
		$sourceData = $result[0]['source_data'];
	}

	$languageId = __("languageId");

	$rawResultTree = null;
	getRawResultTree($testId, $languageId, $rawResultTree);

	$tree = null;
	$result = constructFinalTree($rawResultTree, false, true, $tree);

	$list = null;
	constructFinalTree($rawResultTree, true, false, $list);

	return $result;
}

$domain = null;
$time = null;
$tree = null;
$testId = null;
$list = null;
$result = STATUS_INTERNAL_ERROR;
$sourceData = '';

try
{
	$result = main($tree, $list);
}
catch (Exception $e){}

$IDN = new idna_convert();
$decodedDomain = $IDN->decode($domain);

$result =
array(
'result' => $result,
'domain' => $decodedDomain,
'id' => $testId,
'time' => $time,
'dnscheckversion' => $thisVersion,
'tree' => $tree,
'list' => $list,
'sourceData' => $sourceData
);

echo(json_encode($result));
?>
