
-- phpMyAdmin SQL Dump
-- version 3.5.2.2
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Mar 20 Juin 2017 à 19:21
-- Version du serveur: 10.1.24-MariaDB
-- Version de PHP: 5.2.17

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `u263286397_poubc`
--

-- --------------------------------------------------------

--
-- Structure de la table `composition`
--

CREATE TABLE IF NOT EXISTS `composition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nation` text NOT NULL,
  `player` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=83 ;

--
-- Structure de la table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` text NOT NULL,
  `role` text NOT NULL,
  `api_key` varchar(32) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Contenu de la table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`,`role`, `api_key`, `created_at`) VALUES
(1, 'test', 't@hot.fr', '$2a$10$ba025a0e6afc133d1c6d3ulsIFjiUXce4Q2JJ9pbikjPULRRyzvAW', 'admin', '226f791098549052f704eb37b2ae7999', 1, '2017-04-28 13:13:49'),
(2, 'sedraia', 'taysed93270@hot.fr', '$2a$10$e0ef0815f64d4a917331euCYArjnUMdRr.7wNbfRH1ZG0uC4rulM.', 'gamer', 'fd2e7ac674bf1cbdc0e0683371d50273', 1, '2017-04-28 15:35:15'),
(3, 'sedraia', 'a@hot.fr', '$2a$10$ba025a0e6afc133d1c6d3ulsIFjiUXce4Q2JJ9pbikjPULRRyzvAW', 'gamer', '6b7b98a27f1fe84ee37346e23df97785', 1, '2017-04-28 21:22:51');

-- --------------------------------------------------------

--
-- Structure de la table `user_composition`
--

CREATE TABLE IF NOT EXISTS `user_composition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `composition_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `composition_id` (`composition_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=78 ;

--

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
