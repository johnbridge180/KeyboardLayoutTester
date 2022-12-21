-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Dec 21, 2022 at 02:19 PM
-- Server version: 5.7.34
-- PHP Version: 7.4.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `keyboard_data`
--

-- --------------------------------------------------------

--
-- Table structure for table `key_analysis`
--

CREATE TABLE `key_analysis` (
  `key_value` varchar(10) NOT NULL,
  `layout_type` int(10) UNSIGNED NOT NULL,
  `active_panel` varchar(20) NOT NULL DEFAULT 'main_keyboard_rows',
  `presses` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `presses_landscape` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_timetofind` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_x_up` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_y_up` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_x_down` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_y_down` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_x_up_landscape` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_y_up_landscape` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_x_down_landscape` double UNSIGNED NOT NULL DEFAULT '0',
  `avg_y_down_landscape` double UNSIGNED NOT NULL DEFAULT '0',
  `misses` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `tl_x` double UNSIGNED NOT NULL DEFAULT '0',
  `tl_y` double UNSIGNED NOT NULL DEFAULT '0',
  `br_x` double UNSIGNED NOT NULL DEFAULT '0',
  `br_y` double UNSIGNED NOT NULL DEFAULT '0',
  `tl_x_lkb` double UNSIGNED NOT NULL DEFAULT '0',
  `tl_y_lkb` double UNSIGNED NOT NULL DEFAULT '0',
  `br_x_lkb` double UNSIGNED NOT NULL DEFAULT '0',
  `br_y_lkb` double UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `key_presses`
--

CREATE TABLE `key_presses` (
  `start_timestamp` double NOT NULL,
  `end_timestamp` double NOT NULL,
  `value` varchar(10) NOT NULL,
  `isPortrait` tinyint(1) NOT NULL DEFAULT '1',
  `active_keyboard` varchar(14) NOT NULL,
  `points` mediumtext NOT NULL,
  `layout_type` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `words`
--

CREATE TABLE `words` (
  `start_timestamp` double UNSIGNED NOT NULL,
  `word` text NOT NULL,
  `time` double NOT NULL,
  `keyboard_layout` int(11) NOT NULL,
  `nodelete` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `key_analysis`
--
ALTER TABLE `key_analysis`
  ADD UNIQUE KEY `key_on_board` (`key_value`,`layout_type`,`active_panel`) USING BTREE;

--
-- Indexes for table `key_presses`
--
ALTER TABLE `key_presses`
  ADD PRIMARY KEY (`start_timestamp`);

--
-- Indexes for table `words`
--
ALTER TABLE `words`
  ADD UNIQUE KEY `start` (`start_timestamp`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
