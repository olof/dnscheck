-- $Id$

-- DNSCheck Primary Data

CREATE TABLE IF NOT EXISTS `messages` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `tag` varchar(255) NOT NULL default '',
  `arguments` tinyint(3) unsigned NOT NULL default 0,
  `language` varchar(16) NOT NULL default 'en-US',
  `formatstring` varchar(255) default NULL,
  `description` text default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `langtag` (`tag`,`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `queue` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `domain` varchar(255) default NULL,
  `priority` tinyint(3) unsigned NOT NULL default '0',
  `inprogress` datetime default NULL,
  `tester_pid` int(10) unsigned NULL,
  `source_id` int(10) unsigned NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii;

CREATE TABLE IF NOT EXISTS `tests` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `domain` varchar(255) NOT NULL default '',
  `begin` datetime default NULL,
  `end` datetime default NULL,
  `count_critical` int(10) unsigned default '0',
  `count_error` int(10) unsigned default '0',
  `count_warning` int(10) unsigned default '0',
  `count_notice` int(10) unsigned default '0',
  `count_info` int(10) unsigned default '0',
  `source_id` int(10) unsigned NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii;

CREATE TABLE IF NOT EXISTS `results` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `test_id` int(10) unsigned NOT NULL,
  `line` int(10) unsigned NOT NULL,
  `module_id` int(10) unsigned NOT NULL,
  `parent_module_id` int(10) unsigned NOT NULL,
  `timestamp` datetime default NULL,
  `level` varchar(16) default NULL,
  `message` varchar(255) NOT NULL default '',
  `arg0` varchar(255) default NULL,
  `arg1` varchar(255) default NULL,
  `arg2` varchar(255) default NULL,
  `arg3` varchar(255) default NULL,
  `arg4` varchar(255) default NULL,
  `arg5` varchar(255) default NULL,
  `arg6` varchar(255) default NULL,
  `arg7` varchar(255) default NULL,
  `arg8` varchar(255) default NULL,
  `arg9` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  CONSTRAINT `tests` FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii;


-- Name Service Providers

CREATE TABLE IF NOT EXISTS `nameservers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `nsp_id` int(10) unsigned NULL,
  `nameserver` varchar(255) UNIQUE NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii;

CREATE TABLE IF NOT EXISTS `nsp` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) default '',
  `email` varchar(255) default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Domains and History

CREATE TABLE IF NOT EXISTS `domains` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `domain` varchar(255) NOT NULL default '',
  `last_test` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii;

CREATE TABLE IF NOT EXISTS `delegation_history` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `domain` varchar(255) NOT NULL default '',
  `nameserver` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`domain`,`nameserver`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii;

CREATE TABLE IF NOT EXISTS `source` (
    `id` int(10) unsigned NOT NULL auto_increment,
    `name` varchar(255) NOT NULL,
    `contact` varchar(255),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;