ALTER TABLE `queue` ADD COLUMN
    (`tester_pid` int(10) unsigned NULL,
     `source_id` int(10) unsigned NULL,
     `source_data` varchar(255) NULL,
     `fake_parent_glue` text NULL);
    
ALTER TABLE `tests` ADD COLUMN
    (`source_id` int(10) unsigned NULL,
     `source_data` varchar(255) NULL);
    
CREATE TABLE IF NOT EXISTS `source` (
    `id` int(10) unsigned NOT NULL auto_increment,
    `name` varchar(255) NOT NULL,
    `contact` varchar(255),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
