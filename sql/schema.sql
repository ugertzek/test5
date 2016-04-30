CREATE DATABASE IF NOT EXISTS communit_development;

USE communit_production ;
GRANT ALL ON communit_development.* TO 'root'@'localhost';

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `image_url` varchar(100) DEFAULT NULL,
  `uid` varchar(45) DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL,
  `secret` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

CREATE TABLE `followers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `displayed_as_follower` smallint(6) NOT NULL DEFAULT '0',
  `displayed_as_unfollower` smallint(6) NOT NULL DEFAULT '0',
  `dismissed` smallint(6) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `follow_date` datetime DEFAULT NULL,
  `unfollow_date` datetime DEFAULT '1970-01-01 00:00:00',
  `twitter_id` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `followers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2394 DEFAULT CHARSET=latin1 COMMENT='latin1_swedish_ci';

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

