-- sandbox.sample_teble definition

CREATE TABLE `sample_table` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sample_column` varchar(50) DEFAULT NULL,
  `deleted_flag` char(1) NOT NULL DEFAULT '0',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4;
