-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : ven. 16 oct. 2026 à 14:44
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `btp_erp`
--

-- --------------------------------------------------------

--
-- Structure de la table `achats`
--

CREATE TABLE `achats` (
  `id` int(10) UNSIGNED NOT NULL,
  `reference` varchar(40) DEFAULT NULL,
  `fournisseur_id` int(10) UNSIGNED DEFAULT NULL,
  `chantier_id` int(10) UNSIGNED DEFAULT NULL,
  `date_achat` date DEFAULT NULL,
  `statut` enum('commande','recu','annule') NOT NULL DEFAULT 'commande',
  `montant_total` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `notes` varchar(255) DEFAULT NULL,
  `cree_par` int(10) UNSIGNED DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `achats`
--

INSERT INTO `achats` (`id`, `reference`, `fournisseur_id`, `chantier_id`, `date_achat`, `statut`, `montant_total`, `notes`, `cree_par`, `cree_le`, `modifie_le`) VALUES
(1, 'BC-2026-001', 1, 1, '2026-02-06', 'recu', 4700000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 'BC-2026-002', 2, 2, '2026-03-06', 'recu', 5460000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'BC-2026-003', 3, 3, '2026-04-06', 'recu', 6220000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 'BC-2026-004', 1, 4, '2026-05-06', 'recu', 6980000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 'BC-2026-005', 2, 5, '2026-06-06', 'recu', 7740000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 'BC-2026-006', 3, 1, '2026-07-06', 'commande', 8500000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(7, 'QA-BC-1', 3, 5, '2026-10-01', 'recu', 380000, NULL, 9, '2026-10-12 20:41:26', '2026-10-12 20:41:26');

-- --------------------------------------------------------

--
-- Structure de la table `achat_lignes`
--

CREATE TABLE `achat_lignes` (
  `id` int(10) UNSIGNED NOT NULL,
  `achat_id` int(10) UNSIGNED NOT NULL,
  `materiau_id` int(10) UNSIGNED DEFAULT NULL,
  `designation` varchar(150) NOT NULL,
  `quantite` decimal(12,3) NOT NULL DEFAULT 0.000,
  `prix_unitaire` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `montant` bigint(20) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `achat_lignes`
--

INSERT INTO `achat_lignes` (`id`, `achat_id`, `materiau_id`, `designation`, `quantite`, `prix_unitaire`, `montant`) VALUES
(1, 1, 1, 'Ciment CEM II', 100.000, 38000, 3800000),
(2, 1, 3, 'Sable', 15.000, 60000, 900000),
(3, 2, 1, 'Ciment CEM II', 120.000, 38000, 4560000),
(4, 2, 3, 'Sable', 15.000, 60000, 900000),
(5, 3, 1, 'Ciment CEM II', 140.000, 38000, 5320000),
(6, 3, 3, 'Sable', 15.000, 60000, 900000),
(7, 4, 1, 'Ciment CEM II', 160.000, 38000, 6080000),
(8, 4, 3, 'Sable', 15.000, 60000, 900000),
(9, 5, 1, 'Ciment CEM II', 180.000, 38000, 6840000),
(10, 5, 3, 'Sable', 15.000, 60000, 900000),
(11, 6, 1, 'Ciment CEM II', 200.000, 38000, 7600000),
(12, 6, 3, 'Sable', 15.000, 60000, 900000),
(13, 7, 6, 'QA Ciment', 10.000, 38000, 380000);

-- --------------------------------------------------------

--
-- Structure de la table `chantiers`
--

CREATE TABLE `chantiers` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(30) DEFAULT NULL,
  `nom` varchar(150) NOT NULL,
  `type` enum('batiment','route','autre') NOT NULL DEFAULT 'batiment',
  `client_id` int(10) UNSIGNED DEFAULT NULL,
  `responsable_id` int(10) UNSIGNED DEFAULT NULL,
  `localisation` varchar(255) DEFAULT NULL,
  `date_debut` date DEFAULT NULL,
  `date_fin_prevue` date DEFAULT NULL,
  `date_fin_reelle` date DEFAULT NULL,
  `budget_previsionnel` bigint(20) UNSIGNED DEFAULT NULL,
  `statut` enum('planifie','en_cours','suspendu','termine','annule') NOT NULL DEFAULT 'planifie',
  `description` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `chantiers`
--

INSERT INTO `chantiers` (`id`, `code`, `nom`, `type`, `client_id`, `responsable_id`, `localisation`, `date_debut`, `date_fin_prevue`, `date_fin_reelle`, `budget_previsionnel`, `statut`, `description`, `actif`, `cree_le`, `modifie_le`) VALUES
(1, 'CH-2026-001', 'Immeuble Galaxy Andraharo', 'batiment', 4, 6, 'Andraharo', '2026-03-08', NULL, NULL, 2400000000, 'en_cours', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 'CH-2026-002', 'Rehabilitation RN2 PK12-PK20', 'route', 3, 6, 'RN2', '2026-03-08', NULL, NULL, 3800000000, 'en_cours', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'CH-2026-003', 'Ecole primaire Talatamaty', 'batiment', 1, 6, 'Talatamaty', '2026-03-08', NULL, NULL, 450000000, 'en_cours', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 'CH-2026-004', 'Pont de Mahajanga', 'route', 3, 6, 'Mahajanga', '2026-03-08', NULL, NULL, 5200000000, 'planifie', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 'CH-2026-005', 'Residence Ivandry Park', 'batiment', 2, 6, 'Ivandry', '2026-03-08', NULL, NULL, 2400000000, 'en_cours', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 'QA-CH-1', 'QA-Chantier-Mod', 'batiment', 4, NULL, NULL, NULL, NULL, NULL, 1000000, 'en_cours', NULL, 1, '2026-10-12 20:41:26', '2026-10-12 20:41:26');

-- --------------------------------------------------------

--
-- Structure de la table `clients`
--

CREATE TABLE `clients` (
  `id` int(10) UNSIGNED NOT NULL,
  `nom` varchar(150) NOT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `nif` varchar(30) DEFAULT NULL,
  `stat` varchar(30) DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `clients`
--

INSERT INTO `clients` (`id`, `nom`, `contact`, `telephone`, `email`, `adresse`, `nif`, `stat`, `actif`, `cree_le`, `modifie_le`) VALUES
(1, 'Commune Urbaine de Mahajanga', 'Service technique', '032 11 222 33', NULL, NULL, '4000123450', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 'IMMOBILIER Boeny SARL', 'Rivo A.', '034 05 678 90', NULL, NULL, '4000987651', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'Ministere des Travaux Publics', 'Direction regionale', '020 62 000 00', NULL, NULL, '4000000012', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 'Galaxy Andraharo SA', 'M. Ralaivao', '033 12 345 67', NULL, NULL, '4000543219', NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39');

-- --------------------------------------------------------

--
-- Structure de la table `devis`
--

CREATE TABLE `devis` (
  `id` int(10) UNSIGNED NOT NULL,
  `reference` varchar(40) DEFAULT NULL,
  `client_id` int(10) UNSIGNED DEFAULT NULL,
  `chantier_id` int(10) UNSIGNED DEFAULT NULL,
  `date_devis` date DEFAULT NULL,
  `validite` date DEFAULT NULL,
  `statut` enum('brouillon','envoye','accepte','refuse') NOT NULL DEFAULT 'brouillon',
  `montant_ht` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `tva_taux` decimal(5,2) NOT NULL DEFAULT 20.00,
  `montant_tva` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `montant_ttc` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `notes` varchar(255) DEFAULT NULL,
  `cree_par` int(10) UNSIGNED DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `devis`
--

INSERT INTO `devis` (`id`, `reference`, `client_id`, `chantier_id`, `date_devis`, `validite`, `statut`, `montant_ht`, `tva_taux`, `montant_tva`, `montant_ttc`, `notes`, `cree_par`, `cree_le`, `modifie_le`) VALUES
(1, 'DV-2026-010', 1, 4, '2026-07-08', NULL, 'accepte', 80000000, 20.00, 16000000, 96000000, NULL, 6, '2026-07-08 06:02:39', '2026-10-02 14:28:10'),
(2, 'QA-DV-1', 4, 5, '2026-10-01', NULL, 'accepte', 100000, 20.00, 20000, 120000, NULL, 9, '2026-10-12 20:41:27', '2026-10-12 20:41:27');

-- --------------------------------------------------------

--
-- Structure de la table `devis_lignes`
--

CREATE TABLE `devis_lignes` (
  `id` int(10) UNSIGNED NOT NULL,
  `devis_id` int(10) UNSIGNED NOT NULL,
  `designation` varchar(200) NOT NULL,
  `quantite` decimal(12,3) NOT NULL DEFAULT 1.000,
  `prix_unitaire` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `montant` bigint(20) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `devis_lignes`
--

INSERT INTO `devis_lignes` (`id`, `devis_id`, `designation`, `quantite`, `prix_unitaire`, `montant`) VALUES
(1, 1, 'Etudes et travaux pont', 1.000, 80000000, 80000000),
(2, 2, 'QA Prestation', 1.000, 100000, 100000);

-- --------------------------------------------------------

--
-- Structure de la table `employes`
--

CREATE TABLE `employes` (
  `id` int(10) UNSIGNED NOT NULL,
  `matricule` varchar(30) DEFAULT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) DEFAULT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `poste` varchar(100) DEFAULT NULL,
  `type_contrat` enum('journalier','mensuel','sous_traitant') NOT NULL DEFAULT 'journalier',
  `taux_journalier` int(10) UNSIGNED DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `employes`
--

INSERT INTO `employes` (`id`, `matricule`, `nom`, `prenom`, `telephone`, `poste`, `type_contrat`, `taux_journalier`, `actif`, `cree_le`, `modifie_le`) VALUES
(1, 'M001', 'Rabe', 'Jean', NULL, 'Chef d\'equipe', 'mensuel', 40000, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 'M002', 'Rakoto', 'Paul', NULL, 'Macon', 'journalier', 25000, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'M003', 'Randria', 'Koto', NULL, 'Manoeuvre', 'journalier', 18000, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 'M004', 'Bema', 'Soa', NULL, 'Ferrailleur', 'journalier', 22000, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 'M005', 'Rasoa', 'Naina', NULL, 'Chauffeur', 'mensuel', 30000, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 'M006', 'Tiana', 'Fara', NULL, 'Manoeuvre', 'journalier', 18000, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39');

-- --------------------------------------------------------

--
-- Structure de la table `engins`
--

CREATE TABLE `engins` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(30) DEFAULT NULL,
  `designation` varchar(150) NOT NULL,
  `type` varchar(80) DEFAULT NULL,
  `immatriculation` varchar(30) DEFAULT NULL,
  `etat` enum('disponible','en_service','maintenance','hors_service') NOT NULL DEFAULT 'disponible',
  `cout_horaire` int(10) UNSIGNED DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `factures`
--

CREATE TABLE `factures` (
  `id` int(10) UNSIGNED NOT NULL,
  `reference` varchar(40) DEFAULT NULL,
  `devis_id` int(10) UNSIGNED DEFAULT NULL,
  `client_id` int(10) UNSIGNED DEFAULT NULL,
  `chantier_id` int(10) UNSIGNED DEFAULT NULL,
  `date_facture` date DEFAULT NULL,
  `echeance` date DEFAULT NULL,
  `statut` enum('brouillon','emise','payee_partiel','payee','annulee') NOT NULL DEFAULT 'brouillon',
  `montant_ht` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `tva_taux` decimal(5,2) NOT NULL DEFAULT 20.00,
  `montant_tva` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `montant_ttc` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `montant_paye` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `notes` varchar(255) DEFAULT NULL,
  `cree_par` int(10) UNSIGNED DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `factures`
--

INSERT INTO `factures` (`id`, `reference`, `devis_id`, `client_id`, `chantier_id`, `date_facture`, `echeance`, `statut`, `montant_ht`, `tva_taux`, `montant_tva`, `montant_ttc`, `montant_paye`, `notes`, `cree_par`, `cree_le`, `modifie_le`) VALUES
(1, 'FA-2026-001', NULL, 1, 1, '2026-02-11', '2026-03-13', 'payee', 30000000, 20.00, 6000000, 36000000, 36001000, NULL, 6, '2026-07-08 06:02:39', '2026-10-02 14:28:11'),
(2, 'FA-2026-002', NULL, 2, 2, '2026-03-11', '2026-04-10', 'payee', 38000000, 20.00, 7600000, 45600000, 45600000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'FA-2026-003', NULL, 3, 3, '2026-04-11', '2026-05-11', 'payee', 46000000, 20.00, 9200000, 55200000, 55200000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 'FA-2026-004', NULL, 4, 4, '2026-05-11', '2026-06-10', 'payee', 54000000, 20.00, 10800000, 64800000, 64800000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 'FA-2026-005', NULL, 1, 5, '2026-06-11', '2026-07-11', 'payee_partiel', 62000000, 20.00, 12400000, 74400000, 44640000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 'FA-2026-006', NULL, 2, 1, '2026-07-11', '2026-08-10', 'payee', 70000000, 20.00, 14000000, 84000000, 84000000, NULL, 6, '2026-07-08 06:02:39', '2026-10-13 06:13:26'),
(7, NULL, 1, 1, 4, '2026-10-02', NULL, 'payee_partiel', 80000000, 20.00, 16000000, 96000000, 10000000, NULL, 5, '2026-10-02 14:28:10', '2026-10-14 20:30:41'),
(8, NULL, 2, 4, 5, '2026-10-12', NULL, 'brouillon', 100000, 20.00, 20000, 120000, 0, NULL, 9, '2026-10-12 20:41:27', '2026-10-12 20:41:27');

-- --------------------------------------------------------

--
-- Structure de la table `facture_lignes`
--

CREATE TABLE `facture_lignes` (
  `id` int(10) UNSIGNED NOT NULL,
  `facture_id` int(10) UNSIGNED NOT NULL,
  `designation` varchar(200) NOT NULL,
  `quantite` decimal(12,3) NOT NULL DEFAULT 1.000,
  `prix_unitaire` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `montant` bigint(20) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `facture_lignes`
--

INSERT INTO `facture_lignes` (`id`, `facture_id`, `designation`, `quantite`, `prix_unitaire`, `montant`) VALUES
(1, 1, 'Situation de travaux', 1.000, 30000000, 30000000),
(2, 2, 'Situation de travaux', 1.000, 38000000, 38000000),
(3, 3, 'Situation de travaux', 1.000, 46000000, 46000000),
(4, 4, 'Situation de travaux', 1.000, 54000000, 54000000),
(5, 5, 'Situation de travaux', 1.000, 62000000, 62000000),
(6, 6, 'Situation de travaux', 1.000, 70000000, 70000000),
(7, 7, 'Etudes et travaux pont', 1.000, 80000000, 80000000),
(8, 8, 'QA Prestation', 1.000, 100000, 100000);

-- --------------------------------------------------------

--
-- Structure de la table `fournisseurs`
--

CREATE TABLE `fournisseurs` (
  `id` int(10) UNSIGNED NOT NULL,
  `nom` varchar(150) NOT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `categorie` varchar(100) DEFAULT NULL,
  `nif` varchar(30) DEFAULT NULL,
  `stat` varchar(30) DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `fournisseurs`
--

INSERT INTO `fournisseurs` (`id`, `nom`, `contact`, `telephone`, `email`, `adresse`, `categorie`, `nif`, `stat`, `actif`, `cree_le`, `modifie_le`) VALUES
(1, 'Quincaillerie Mahajanga', NULL, '032 00 111 22', NULL, NULL, 'materiaux', NULL, NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 'Ciments de Madagascar', NULL, '020 22 333 44', NULL, NULL, 'materiaux', NULL, NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'Location Engins Boeny', NULL, '034 55 666 77', NULL, NULL, 'location engins', NULL, NULL, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39');

-- --------------------------------------------------------

--
-- Structure de la table `journal_audit`
--

CREATE TABLE `journal_audit` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entite` varchar(100) DEFAULT NULL,
  `entite_id` varchar(64) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `adresse_ip` varchar(45) DEFAULT NULL,
  `agent_utilisateur` varchar(255) DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `journal_audit`
--

INSERT INTO `journal_audit` (`id`, `utilisateur_id`, `action`, `entite`, `entite_id`, `details`, `adresse_ip`, `agent_utilisateur`, `cree_le`) VALUES
(2, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'curl/7.53.1', '2026-07-08 06:03:39'),
(3, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:04:16'),
(4, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:04:17'),
(5, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:04:58'),
(6, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:01'),
(7, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:06'),
(8, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:07'),
(9, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:11'),
(10, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:13'),
(11, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:14'),
(12, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:16'),
(13, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:17'),
(14, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:18'),
(15, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:19'),
(16, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:21'),
(17, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:22'),
(18, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:30'),
(19, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:31'),
(20, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:33'),
(21, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:34'),
(22, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:36'),
(23, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:37'),
(24, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:40'),
(25, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:05:41'),
(26, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'curl/7.53.1', '2026-07-08 06:06:06'),
(27, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:06:09'),
(28, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:06:11'),
(29, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:47'),
(30, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:49'),
(31, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:50'),
(32, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:51'),
(33, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:51'),
(34, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:53'),
(35, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:54'),
(36, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:55'),
(37, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:07:55'),
(38, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:08:12'),
(39, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:08:13'),
(40, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:36:36'),
(41, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:40:49'),
(42, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 06:40:50'),
(43, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:56:49'),
(44, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:56:50'),
(45, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:56:51'),
(46, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:56:51'),
(47, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:59:25'),
(48, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:59:29'),
(49, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:59:34'),
(50, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:59:42'),
(51, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 06:59:49'),
(52, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:05:39'),
(53, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:05:40'),
(54, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:05:41'),
(55, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:35'),
(56, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:36'),
(57, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:37'),
(58, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:38'),
(59, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:39'),
(60, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:39'),
(61, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:40'),
(62, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:41'),
(63, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:42'),
(64, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:42'),
(65, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:11:43'),
(66, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'curl/7.53.1', '2026-07-08 07:13:15'),
(67, 5, 'parametres.modification', 'parametres', NULL, NULL, '::1', 'curl/7.53.1', '2026-07-08 07:13:15'),
(68, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'curl/7.53.1', '2026-07-08 07:13:16'),
(69, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'curl/7.53.1', '2026-07-08 07:13:43'),
(70, 5, 'parametres.logo', 'parametres', NULL, '{\"fichier\":\"uploads\\/logo-d98c0f78c99b.png\"}', '::1', 'curl/7.53.1', '2026-07-08 07:13:43'),
(71, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'curl/7.53.1', '2026-07-08 07:14:15'),
(72, 5, 'parametres.logo', 'parametres', NULL, '{\"fichier\":\"uploads\\/logo-6a287e920271.png\"}', '::1', 'curl/7.53.1', '2026-07-08 07:14:15'),
(73, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:14:25'),
(74, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:14:26'),
(75, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:26'),
(76, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:31'),
(77, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:34'),
(78, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:35'),
(79, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:36'),
(80, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:40'),
(81, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:41'),
(82, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:43'),
(83, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:44'),
(84, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:45'),
(85, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:46'),
(86, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 07:24:47'),
(87, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:44:03'),
(88, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:44:04'),
(89, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:44:07'),
(90, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:44:08'),
(91, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:46:47'),
(92, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:46:48'),
(93, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:47:05'),
(94, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 07:47:07'),
(95, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:19'),
(96, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:24'),
(97, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:34'),
(98, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:34'),
(99, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:38'),
(100, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:39'),
(101, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:41'),
(102, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:41'),
(103, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:43'),
(104, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:43'),
(105, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:44'),
(106, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:50'),
(107, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:53'),
(108, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:03:54'),
(109, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 08:06:44'),
(110, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', '2026-07-08 08:06:45'),
(111, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:50'),
(112, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:54'),
(113, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:55'),
(114, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:56'),
(115, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:57'),
(116, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:58'),
(117, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:58'),
(118, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:07:59'),
(119, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:08:00'),
(120, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:08:01'),
(121, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:08:01'),
(122, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:08:02'),
(123, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:08:03'),
(124, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:12:52'),
(125, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:13:36'),
(126, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:18:46'),
(127, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:19:05'),
(128, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:19:10'),
(129, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:19:46'),
(130, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:19:51'),
(131, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:19:56'),
(132, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:20:18'),
(133, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:20:21'),
(134, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:20:29'),
(135, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:20:34'),
(136, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:20:45'),
(137, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:20:50'),
(138, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:16'),
(139, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:25'),
(140, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:28'),
(141, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:30'),
(142, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:33'),
(143, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:36'),
(144, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:21:39'),
(145, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:30:40'),
(146, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 08:33:45'),
(147, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-08 16:20:02'),
(148, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-09 10:49:03'),
(149, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-09 10:49:06'),
(150, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:45'),
(151, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:45'),
(152, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:45'),
(153, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:45'),
(154, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:52'),
(155, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:53'),
(156, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:56'),
(157, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:57'),
(158, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:58'),
(159, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:44:58'),
(160, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:45:01'),
(161, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:45:02'),
(162, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:45:03'),
(163, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:45:04'),
(164, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:45:05'),
(165, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:45:06'),
(166, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:18'),
(167, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:20'),
(168, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:32'),
(169, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:33'),
(170, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:34'),
(171, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:36'),
(172, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:38'),
(173, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:39'),
(174, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:40'),
(175, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:42'),
(176, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:43'),
(177, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:44'),
(178, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:55'),
(179, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:46:56'),
(180, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:47:34'),
(181, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:48:01'),
(182, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:48:02'),
(183, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:48:03'),
(184, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-18 07:48:04'),
(185, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:02:56'),
(186, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:02:56'),
(187, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:02:56'),
(188, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:02:57'),
(189, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:03:06'),
(190, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:03:07'),
(191, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:03:09'),
(192, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:03:11'),
(193, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:03:13'),
(194, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:04:41'),
(195, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:04:43'),
(196, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:04:47'),
(197, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:04:59'),
(198, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:05:01'),
(199, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 09:05:03'),
(200, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:09:47'),
(201, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:09:52'),
(202, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:10:15'),
(203, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:10:21'),
(204, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:10:33'),
(205, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:10:34'),
(206, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:10:47'),
(207, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:10:56'),
(208, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:11:01'),
(209, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:11:26'),
(210, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:11:51'),
(211, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:11:55'),
(212, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:12:03'),
(213, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:12:16'),
(214, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:12:30'),
(215, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:12:54'),
(216, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:13:10'),
(217, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:13:30'),
(218, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:14:01'),
(219, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:14:04'),
(220, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:14:46'),
(221, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:15:47'),
(222, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:19:45'),
(223, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"technicien1@entreprise.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-18 10:19:52'),
(224, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"admin@entreprise.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-09-19 05:15:10'),
(225, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"directeur@digitalchantier.mg\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-21 05:32:29'),
(226, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:02'),
(227, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:03'),
(228, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:17'),
(229, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:26'),
(230, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:55'),
(231, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:55'),
(232, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:25:58'),
(233, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:03'),
(234, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:13'),
(235, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:13'),
(236, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:32'),
(237, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:33'),
(238, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:34'),
(239, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:44'),
(240, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:26:57'),
(241, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:27:09'),
(242, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:27:26'),
(243, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:27:38'),
(244, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 11:27:40'),
(245, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:01:04'),
(246, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:01:04'),
(247, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:01:14');
INSERT INTO `journal_audit` (`id`, `utilisateur_id`, `action`, `entite`, `entite_id`, `details`, `adresse_ip`, `agent_utilisateur`, `cree_le`) VALUES
(248, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:01:25'),
(249, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:01:36'),
(250, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:02:58'),
(251, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:03:01'),
(252, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:04:41'),
(253, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:04:43'),
(254, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:04:45'),
(255, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:04:48'),
(256, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:04:51'),
(257, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:04:52'),
(258, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:08:53'),
(259, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:09:08'),
(260, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:09:10'),
(261, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:09:11'),
(262, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:18'),
(263, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:20'),
(264, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:21'),
(265, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:23'),
(266, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:27'),
(267, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:28'),
(268, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:30'),
(269, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:12:31'),
(270, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:25:48'),
(271, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:11'),
(272, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:16'),
(273, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:16'),
(274, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:18'),
(275, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:19'),
(276, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:21'),
(277, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:23'),
(278, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:24'),
(279, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 12:27:30'),
(280, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:31:48'),
(281, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:31:52'),
(282, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"technicien1@entreprise.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:32:09'),
(283, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:17'),
(284, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:17'),
(285, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:17'),
(286, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:24'),
(287, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:25'),
(288, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:29'),
(289, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:35'),
(290, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:37'),
(291, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:40'),
(292, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:54:56'),
(293, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 13:55:05'),
(294, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:33'),
(295, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:35'),
(296, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:37'),
(297, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:39'),
(298, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:40'),
(299, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:55'),
(300, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:56'),
(301, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:03:57'),
(302, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:04:00'),
(303, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:04:11'),
(304, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:04:12'),
(305, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:04:41'),
(306, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:23:12'),
(307, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:23:14'),
(308, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:24:14'),
(309, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:24:14'),
(310, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:24:20'),
(311, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:24:50'),
(312, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:24:50'),
(313, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:25:22'),
(314, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:25:26'),
(315, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:25:26'),
(316, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:28'),
(317, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:34'),
(318, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:34'),
(319, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:41'),
(320, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:41'),
(321, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:47'),
(322, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:49'),
(323, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:50'),
(324, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:54'),
(325, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:40:55'),
(326, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:04'),
(327, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:07'),
(328, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:10'),
(329, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:10'),
(330, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:14'),
(331, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:21'),
(332, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:27'),
(333, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:41:28'),
(334, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:08'),
(335, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:08'),
(336, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:11'),
(337, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:13'),
(338, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:14'),
(339, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:17'),
(340, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:19'),
(341, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:19'),
(342, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 14:43:22'),
(343, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:26'),
(344, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:27'),
(345, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:32'),
(346, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:32'),
(347, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:35'),
(348, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:53'),
(349, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:57'),
(350, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:04:57'),
(351, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:05:00'),
(352, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:05:22'),
(353, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:05:24'),
(354, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 11:16:58'),
(355, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 11:37:21'),
(356, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 11:37:21'),
(357, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 11:41:54'),
(358, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:42:04'),
(359, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:42:07'),
(360, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:42:08'),
(361, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 11:48:23'),
(362, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 11:48:23'),
(363, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:48:30'),
(364, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:53:20'),
(365, 7, 'mot_de_passe.change', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:54:27'),
(366, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:54:33'),
(367, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:54:34'),
(368, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:55:00'),
(369, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:55:05'),
(370, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:56:21'),
(371, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:56:21'),
(372, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:56:23'),
(373, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:56:25'),
(374, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:56:26'),
(375, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:56:28'),
(376, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:57:18'),
(377, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:58:25'),
(378, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:58:27'),
(379, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:58:27'),
(380, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:58:28'),
(381, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:58:37'),
(382, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 11:58:56'),
(383, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:01:49'),
(384, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:01:52'),
(385, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:01:53'),
(386, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:01:53'),
(387, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:01:55'),
(388, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:01:57'),
(389, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:21'),
(390, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:28'),
(391, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:31'),
(392, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:32'),
(393, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:32'),
(394, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:34'),
(395, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:36'),
(396, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:44'),
(397, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:46'),
(398, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:48'),
(399, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:55'),
(400, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:09:57'),
(401, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:10:15'),
(402, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:10:23'),
(403, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:10:23'),
(404, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:10:25'),
(405, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:10:28'),
(406, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:10:42'),
(407, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:11:07'),
(408, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:11:09'),
(409, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:11:14'),
(410, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:11:16'),
(411, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:11:54'),
(412, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:11:59'),
(413, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:12:06'),
(414, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:21:45'),
(415, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:21:52'),
(416, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:22:01'),
(417, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:22:03'),
(418, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:22:14'),
(419, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:22:14'),
(420, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:22:22'),
(421, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:22:29'),
(422, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:24:18'),
(423, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:24:20'),
(424, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:24:22'),
(425, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:24:38'),
(426, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:04'),
(427, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:07'),
(428, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:09'),
(429, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:11'),
(430, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:13'),
(431, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:15'),
(432, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:18'),
(433, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:26'),
(434, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:29:29'),
(435, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:13'),
(436, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:14'),
(437, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:16'),
(438, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:19'),
(439, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:22'),
(440, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:26'),
(441, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:30:30'),
(442, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:33:22'),
(443, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:33:22'),
(444, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:33:22'),
(445, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:35:25'),
(446, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:00'),
(447, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:20'),
(448, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:24'),
(449, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:25'),
(450, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:26'),
(451, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:27'),
(452, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:28'),
(453, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:29'),
(454, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:30'),
(455, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:31'),
(456, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:37:33'),
(457, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:40:27'),
(458, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:45:26'),
(459, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 12:55:36'),
(460, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:19:13'),
(461, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:19:14'),
(462, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:22:15'),
(463, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:22:18'),
(464, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:22:20'),
(465, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:22:21'),
(466, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:22:29'),
(467, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:22:32'),
(468, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:03'),
(469, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:07'),
(470, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:07'),
(471, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:07'),
(472, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:08'),
(473, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:14'),
(474, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:22'),
(475, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:29'),
(476, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:30'),
(477, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:32'),
(478, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:30:35'),
(479, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:31:01'),
(480, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:31:04'),
(481, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:31:44'),
(482, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:31:46'),
(483, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:32:13');
INSERT INTO `journal_audit` (`id`, `utilisateur_id`, `action`, `entite`, `entite_id`, `details`, `adresse_ip`, `agent_utilisateur`, `cree_le`) VALUES
(484, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:32:15'),
(485, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:32:22'),
(486, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:33:12'),
(487, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:33:13'),
(488, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:33:13'),
(489, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:33:13'),
(490, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Fold) AppleWebKit/537.36 (KHTML, like Gecko) Edg/153.0.0.0 Mobile Safari/537.36', '2026-09-24 13:35:30'),
(491, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:45:54'),
(492, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:46:09'),
(493, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:46:25'),
(494, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:02'),
(495, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:03'),
(496, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:06'),
(497, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:09'),
(498, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:12'),
(499, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:13'),
(500, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:17'),
(501, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:31'),
(502, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:53'),
(503, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:47:55'),
(504, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:48:14'),
(505, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 13:48:15'),
(506, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:16:49'),
(507, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:16:50'),
(508, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:16:55'),
(509, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:16:55'),
(510, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:16:58'),
(511, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:16:59'),
(512, 8, 'profil.modifie', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:17:42'),
(513, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:17:52'),
(514, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:20:46'),
(515, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:20:46'),
(516, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 14:20:49'),
(517, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:51:31'),
(518, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:51:32'),
(519, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:52:04'),
(520, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:53:28'),
(521, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:53:45'),
(522, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:54:35'),
(523, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:55:07'),
(524, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:55:20'),
(525, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 05:57:21'),
(526, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:00:42'),
(527, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:00:47'),
(528, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:01:02'),
(529, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:01:06'),
(530, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:01:08'),
(531, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:01:17'),
(532, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:01:46'),
(533, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:02:02'),
(534, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:02:07'),
(535, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:02:22'),
(536, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:02:55'),
(537, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:05:39'),
(538, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:05:49'),
(539, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:06:06'),
(540, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 06:06:08'),
(541, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:10:26'),
(542, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:10:26'),
(543, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:42:13'),
(544, 8, 'mot_de_passe.reinitialise', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:54:12'),
(545, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"rakotomamonjyluciano1707@gmail.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:54:16'),
(546, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:57:26'),
(547, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:57:26'),
(548, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:57:43'),
(549, 8, 'profil.modifie', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:58:19'),
(550, 8, 'profil.modifie', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:58:26'),
(551, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:58:38'),
(552, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:59:00'),
(553, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:59:00'),
(554, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:59:13'),
(555, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:59:52'),
(556, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 11:59:52'),
(557, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:12:36'),
(558, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:12:37'),
(559, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:24:03'),
(560, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:24:03'),
(561, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:24:09'),
(562, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:24:12'),
(563, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:24:14'),
(564, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-28 12:24:16'),
(565, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 12:01:17'),
(566, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 12:01:17'),
(567, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 12:27:55'),
(568, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 12:27:57'),
(569, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 13:09:29'),
(570, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 13:09:30'),
(571, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-29 13:48:32'),
(572, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:02:42'),
(573, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:02:43'),
(574, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:02:46'),
(575, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:04:06'),
(576, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:04:07'),
(577, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:04:09'),
(578, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:10:45'),
(579, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 12:13:08'),
(580, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 12:31:11'),
(581, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 12:31:24'),
(582, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:32:06'),
(583, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-10-01 12:32:07'),
(584, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 13:37:38'),
(585, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"directeur@digitalchantier.mg\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-02 14:16:58'),
(586, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-02 14:17:39'),
(587, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"naina.compta@digitalchantier.mg\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-02 14:17:39'),
(588, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"mickaramtovo@gmail.com\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-02 14:17:40'),
(589, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"mobile\"}', '::1', 'curl/8.13.0', '2026-10-02 14:23:02'),
(590, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"directeur@digitalchantier.mg\"}', '::1', 'curl/8.13.0', '2026-10-02 14:26:05'),
(591, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"mobile\"}', '::1', 'curl/8.13.0', '2026-10-02 14:27:59'),
(592, 5, 'devis.facturation', 'devis', '1', '{\"facture_id\":7}', '::1', 'curl/8.13.0', '2026-10-02 14:28:10'),
(593, 5, 'facture.paiement', 'facture', '1', '{\"montant\":1000}', '::1', 'curl/8.13.0', '2026-10-02 14:28:11'),
(594, 5, 'parametres.modification', 'parametres', NULL, NULL, '::1', 'curl/8.13.0', '2026-10-02 14:28:14'),
(595, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'curl/8.13.0', '2026-10-02 14:28:38'),
(596, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"mobile\"}', '::1', 'curl/8.13.0', '2026-10-02 14:35:44'),
(597, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"mobile\"}', '::1', 'curl/8.13.0', '2026-10-02 14:36:21'),
(598, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 14:21:33'),
(599, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"mickaramtovo@gmail.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 11:29:52'),
(600, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 11:30:01'),
(601, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:30:37'),
(602, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:30:38'),
(603, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:30:38'),
(604, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:30:39'),
(605, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:35:14'),
(606, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:36:05'),
(607, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 11:36:12'),
(608, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"naina.compta@digitalchantier.mg\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 11:52:46'),
(609, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:33:27'),
(610, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:33:37'),
(611, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:33:58'),
(612, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:34:18'),
(613, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:34:30'),
(614, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:36:34'),
(615, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:36:38'),
(616, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:36:46'),
(617, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 12:36:58'),
(618, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:40:20'),
(619, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:40:31'),
(620, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:40:54'),
(621, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:40:57'),
(622, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:41:16'),
(623, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:41:30'),
(624, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:41:40'),
(625, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:41:44'),
(626, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:41:52'),
(627, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 13:41:57'),
(628, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 13:48:00'),
(629, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:23:26'),
(630, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:23:32'),
(631, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:23:47'),
(632, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:23:59'),
(633, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:24:04'),
(634, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:24:32'),
(635, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 14:24:34'),
(636, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 19:50:13'),
(637, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 19:50:14'),
(638, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 19:50:17'),
(639, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:50:33'),
(640, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:50:34'),
(641, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:50:39'),
(642, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:50:57'),
(643, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:51:12'),
(644, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:51:15'),
(645, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:51:16'),
(646, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:51:20'),
(647, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:51:37'),
(648, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:54:41'),
(649, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:54:42'),
(650, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:54:55'),
(651, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:54:58'),
(652, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:55:01'),
(653, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:55:05'),
(654, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:55:18'),
(655, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:55:35'),
(656, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 11:53:27'),
(657, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 12:16:23'),
(658, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 12:53:20'),
(659, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 13:16:33'),
(660, 8, 'stock.mouvement', 'materiau', '4', '{\"type\":\"entree\",\"quantite\":10}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 13:17:55'),
(661, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:18:55'),
(662, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:18:56'),
(663, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:15'),
(664, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:18'),
(665, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:18'),
(666, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:31'),
(667, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:38'),
(668, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:42'),
(669, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:47'),
(670, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-08 13:23:50'),
(671, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 11:07:12'),
(672, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 11:07:12'),
(673, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 11:07:13'),
(674, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 11:07:13'),
(675, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 11:07:17'),
(676, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 11:37:36'),
(677, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 11:58:35'),
(678, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 12:00:39'),
(679, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 12:00:59'),
(680, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 12:38:15'),
(681, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:02:24'),
(682, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:02:25'),
(683, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:02:33'),
(684, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:02:45'),
(685, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:02:55'),
(686, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:03:10'),
(687, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:03:33'),
(688, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:03:38'),
(689, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:03:45'),
(690, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:03:55'),
(691, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:04:02'),
(692, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:04:15'),
(693, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:04:18'),
(694, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:04:25'),
(695, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:04:50'),
(696, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:04:53'),
(697, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:05:00'),
(698, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:19:34'),
(699, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:19:36'),
(700, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"rakotomamonjyluciano1707@gmail.com\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:19:36'),
(701, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:23:25'),
(702, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:32:21'),
(703, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:33:36'),
(704, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:33:36'),
(705, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:33:51'),
(706, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:34:00'),
(707, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:34:05'),
(708, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:34:18'),
(709, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:34:21'),
(710, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:34:39'),
(711, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:34:45'),
(712, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:35:40'),
(713, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:35:53'),
(714, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:36:00'),
(715, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:36:04'),
(716, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:49:52'),
(717, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:54:28'),
(718, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:54:29'),
(719, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:54:46'),
(720, 5, 'stock.mouvement', 'materiau', '1', '{\"type\":\"entree\",\"quantite\":1}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:54:46'),
(721, 5, 'stock.mouvement', 'materiau', '1', '{\"type\":\"sortie\",\"quantite\":1}', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-09 13:54:46'),
(722, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 13:59:15'),
(723, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:06');
INSERT INTO `journal_audit` (`id`, `utilisateur_id`, `action`, `entite`, `entite_id`, `details`, `adresse_ip`, `agent_utilisateur`, `cree_le`) VALUES
(724, 7, 'connexion', 'utilisateur', '7', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:33'),
(725, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:33'),
(726, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:39'),
(727, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:43'),
(728, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:50'),
(729, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:55'),
(730, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:02:03'),
(731, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:02:07'),
(732, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 07:13:27'),
(733, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-12 20:02:21'),
(734, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-12 20:02:21'),
(735, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-12 20:02:35'),
(736, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-12 20:02:37'),
(737, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"directeur@digitalchantier.mg\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:24:38'),
(738, 9, 'connexion', 'utilisateur', '9', '{\"client\":\"web\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:39:43'),
(739, 9, 'connexion', 'utilisateur', '9', '{\"client\":\"web\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:25'),
(740, 9, 'employe.creation', 'employe', '7', '{\"nom\":\"QA-Employe\",\"prenom\":\"Test\",\"taux_journalier\":20000,\"type_contrat\":\"journalier\",\"actif\":true}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:25'),
(741, 9, 'employe.modification', 'employe', '7', '{\"nom\":\"QA-Employe-Mod\",\"prenom\":\"Test\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:25'),
(742, 9, 'employe.suppression', 'employe', '7', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:25'),
(743, 9, 'client.creation', 'client', '5', '{\"nom\":\"QA-Client\",\"contact\":\"Test\",\"telephone\":\"0300000000\",\"actif\":true}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(744, 9, 'client.modification', 'client', '5', '{\"nom\":\"QA-Client-Mod\",\"contact\":\"Test\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(745, 9, 'client.suppression', 'client', '5', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(746, 9, 'fournisseur.creation', 'fournisseur', '4', '{\"nom\":\"QA-Fournisseur\",\"categorie\":\"materiaux\",\"actif\":true}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(747, 9, 'fournisseur.modification', 'fournisseur', '4', '{\"nom\":\"QA-Fournisseur-Mod\",\"categorie\":\"materiaux\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(748, 9, 'fournisseur.suppression', 'fournisseur', '4', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(749, 9, 'engin.creation', 'engin', '1', '{\"designation\":\"QA-Engin\",\"type\":\"camion\",\"etat\":\"disponible\",\"cout_horaire\":50000,\"actif\":true}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(750, 9, 'engin.modification', 'engin', '1', '{\"designation\":\"QA-Engin-Mod\",\"etat\":\"maintenance\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(751, 9, 'engin.suppression', 'engin', '1', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(752, 9, 'materiau.creation', 'materiau', '7', '{\"designation\":\"QA-Materiau\",\"unite\":\"sac\",\"prix_unitaire\":1000,\"seuil_alerte\":5,\"actif\":true}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(753, 9, 'materiau.modification', 'materiau', '7', '{\"designation\":\"QA-Materiau-Mod\",\"prix_unitaire\":1500}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(754, 9, 'materiau.suppression', 'materiau', '7', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(755, 9, 'chantier.creation', 'chantier', '6', '{\"code\":\"QA-CH-1\",\"nom\":\"QA-Chantier\",\"type\":\"batiment\",\"statut\":\"planifie\",\"budget_previsionnel\":1000000,\"client_id\":4}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(756, 9, 'chantier.modification', 'chantier', '6', '{\"nom\":\"QA-Chantier-Mod\",\"statut\":\"en_cours\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(757, 9, 'lot.creation', 'lot', '10', '{\"nom\":\"QA-Lot\",\"budget_previsionnel\":500000,\"avancement\":10,\"statut\":\"a_faire\",\"ordre\":1,\"chantier_id\":6}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(758, 9, 'lot.modification', 'lot', '10', '{\"nom\":\"QA-Lot-Mod\",\"avancement\":50,\"statut\":\"en_cours\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(759, 9, 'lot.suppression', 'lot', '10', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(760, 9, 'pointage.feuille', 'chantier', '6', '{\"date\":\"2026-10-01\",\"lignes\":1}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(761, 9, 'achat.creation', 'achat', '7', '{\"montant\":null}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(762, 9, 'achat.reception', 'achat', '7', '{\"entrees_stock\":1}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(763, 9, 'achat.creation', 'achat', '8', '{\"montant\":null}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(764, 9, 'achat.annulation', 'achat', '8', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(765, 9, 'achat.suppression', 'achat', '8', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(766, 9, 'stock.mouvement', 'materiau', '6', '{\"type\":\"ajustement\",\"quantite\":5}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:26'),
(767, 9, 'devis.creation', 'devis', '2', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(768, 9, 'devis.statut', 'devis', '2', '{\"statut\":\"envoye\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(769, 9, 'devis.facturation', 'devis', '2', '{\"facture_id\":8}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(770, 9, 'facture.creation', 'facture', '9', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(771, 9, 'facture.emission', 'facture', '9', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(772, 9, 'facture.paiement', 'facture', '9', '{\"montant\":50000}', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(773, 9, 'facture.suppression', 'facture', '9', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(774, 9, 'parametres.modification', 'parametres', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.6456', '2026-10-12 20:41:27'),
(775, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:12:16'),
(776, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:12:16'),
(777, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:12:41'),
(778, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:12:48'),
(779, 7, 'facture.paiement', 'facture', '6', '{\"montant\":33600000}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:13:26'),
(780, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:13:55'),
(781, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:15'),
(782, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:19'),
(783, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:30'),
(784, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:43'),
(785, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:45'),
(786, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:49'),
(787, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:50'),
(788, 7, 'token.refresh', 'utilisateur', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:14:58'),
(789, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 06:15:06'),
(790, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"hery.chef@digitalchantier.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-13 11:21:21'),
(791, NULL, 'connexion.echec', 'utilisateur', NULL, '{\"email\":\"hery.chef@digitalchantier.com\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-13 11:21:28'),
(792, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-13 11:22:29'),
(793, 6, 'token.refresh', 'utilisateur', '6', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-13 11:39:53'),
(794, 6, 'connexion', 'utilisateur', '6', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-13 12:04:03'),
(795, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 19:33:30'),
(796, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:42:39'),
(797, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:42:40'),
(798, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:43:47'),
(799, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:44:22'),
(800, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:44:30'),
(801, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:44:55'),
(802, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:45:24'),
(803, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:45:31'),
(804, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:45:37'),
(805, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:46:02'),
(806, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:47:08'),
(807, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:47:12'),
(808, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:47:21'),
(809, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:48:17'),
(810, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:48:20'),
(811, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 19:48:31'),
(812, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:48:42'),
(813, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:48:52'),
(814, 8, 'token.refresh', 'utilisateur', '8', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:49:12'),
(815, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 19:50:00'),
(816, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 19:50:05'),
(817, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:52:22'),
(818, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:52:33'),
(819, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:52:34'),
(820, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:52:42'),
(821, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-14 19:53:05'),
(822, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:54:24'),
(823, 5, 'parametres.logo', 'parametres', NULL, '{\"fichier\":\"uploads\\/logo-6055aeee2f77.png\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 19:55:02'),
(824, 5, 'parametres.modification', 'parametres', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 19:55:09'),
(825, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 19:55:16'),
(826, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 20:29:13'),
(827, 5, 'facture.emission', 'facture', '7', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 20:29:49'),
(828, 5, 'facture.paiement', 'facture', '7', '{\"montant\":10000000}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-14 20:30:41'),
(829, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 20:39:31'),
(830, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 20:39:38'),
(831, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 20:39:40'),
(832, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 20:39:48'),
(833, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 20:39:57'),
(834, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 20:40:01'),
(835, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 10:51:46'),
(836, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 10:51:55'),
(837, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 10:51:57'),
(838, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 11:03:11'),
(839, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 11:03:26'),
(840, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 11:03:28'),
(841, 8, 'connexion', 'utilisateur', '8', '{\"client\":\"mobile\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 11:06:04'),
(842, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 11:06:49'),
(843, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 10:43:10'),
(844, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 10:43:11'),
(845, NULL, 'deconnexion', 'utilisateur', NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 10:43:19'),
(846, 5, 'connexion', 'utilisateur', '5', '{\"client\":\"web\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 10:43:26'),
(847, 5, 'token.refresh', 'utilisateur', '5', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 10:43:27');

-- --------------------------------------------------------

--
-- Structure de la table `lots`
--

CREATE TABLE `lots` (
  `id` int(10) UNSIGNED NOT NULL,
  `chantier_id` int(10) UNSIGNED NOT NULL,
  `nom` varchar(150) NOT NULL,
  `budget_previsionnel` bigint(20) UNSIGNED DEFAULT NULL,
  `avancement` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `statut` enum('a_faire','en_cours','termine') NOT NULL DEFAULT 'a_faire',
  `ordre` int(11) NOT NULL DEFAULT 0,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `lots`
--

INSERT INTO `lots` (`id`, `chantier_id`, `nom`, `budget_previsionnel`, `avancement`, `statut`, `ordre`, `cree_le`, `modifie_le`) VALUES
(1, 1, 'Fondations', 600000000, 100, 'termine', 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 1, 'Gros oeuvre', 1000000000, 70, 'en_cours', 2, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 1, 'Second oeuvre', 800000000, 20, 'en_cours', 3, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 2, 'Terrassement', 1500000000, 80, 'en_cours', 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 2, 'Bitume', 2300000000, 20, 'en_cours', 2, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 3, 'Batiment', 450000000, 88, 'en_cours', 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(7, 4, 'Etudes', 200000000, 30, 'en_cours', 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(8, 5, 'Fondations', 700000000, 90, 'termine', 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(9, 5, 'Elevation', 1700000000, 45, 'en_cours', 2, '2026-07-08 06:02:39', '2026-07-08 06:02:39');

-- --------------------------------------------------------

--
-- Structure de la table `materiaux`
--

CREATE TABLE `materiaux` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(30) DEFAULT NULL,
  `designation` varchar(150) NOT NULL,
  `unite` varchar(20) NOT NULL DEFAULT 'unite',
  `prix_unitaire` int(10) UNSIGNED DEFAULT NULL,
  `seuil_alerte` int(10) UNSIGNED DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `materiaux`
--

INSERT INTO `materiaux` (`id`, `code`, `designation`, `unite`, `prix_unitaire`, `seuil_alerte`, `actif`, `cree_le`, `modifie_le`) VALUES
(1, 'CIM01', 'Ciment CEM II 42.5', 'sac', 38000, 100, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 'FER12', 'Fer a beton 12mm', 'barre', 45000, 50, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 'SAB01', 'Sable', 'm3', 60000, 20, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 'GRV01', 'Gravillon', 'm3', 80000, 20, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 'PAR01', 'Parpaing 20', 'unite', 2500, 500, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 'GAS01', 'Gasoil', 'litre', 5200, 200, 1, '2026-07-08 06:02:39', '2026-07-08 06:02:39');

-- --------------------------------------------------------

--
-- Structure de la table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `fichier` varchar(255) NOT NULL,
  `lot` int(10) UNSIGNED NOT NULL,
  `execute_le` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `migrations`
--

INSERT INTO `migrations` (`id`, `fichier`, `lot`, `execute_le`) VALUES
(1, '0001_socle.sql', 1, '2026-07-07 17:51:43'),
(2, '0002_utilisateurs.sql', 2, '2026-07-07 18:09:28'),
(3, '0003_referentiels.sql', 3, '2026-07-07 18:19:40'),
(4, '0004_chantiers.sql', 4, '2026-07-07 18:33:23'),
(5, '0005_pointages.sql', 5, '2026-07-07 18:48:27'),
(6, '0006_achats_stock.sql', 6, '2026-07-07 18:53:55'),
(7, '0007_facturation.sql', 7, '2026-07-07 19:02:58'),
(8, '0008_montants_bigint.sql', 8, '2026-07-08 06:02:39'),
(9, '0009_reinitialisation_mot_de_passe.sql', 9, '2026-09-24 14:08:08');

-- --------------------------------------------------------

--
-- Structure de la table `mouvements_stock`
--

CREATE TABLE `mouvements_stock` (
  `id` int(10) UNSIGNED NOT NULL,
  `materiau_id` int(10) UNSIGNED NOT NULL,
  `type` enum('entree','sortie','ajustement') NOT NULL,
  `quantite` decimal(12,3) NOT NULL DEFAULT 0.000,
  `chantier_id` int(10) UNSIGNED DEFAULT NULL,
  `achat_id` int(10) UNSIGNED DEFAULT NULL,
  `motif` varchar(255) DEFAULT NULL,
  `date_mouvement` date DEFAULT NULL,
  `cree_par` int(10) UNSIGNED DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `mouvements_stock`
--

INSERT INTO `mouvements_stock` (`id`, `materiau_id`, `type`, `quantite`, `chantier_id`, `achat_id`, `motif`, `date_mouvement`, `cree_par`, `cree_le`) VALUES
(1, 1, 'entree', 60.000, NULL, NULL, 'Stock initial', '2026-05-08', NULL, '2026-07-08 06:02:39'),
(2, 2, 'entree', 220.000, NULL, NULL, 'Stock initial', '2026-05-08', NULL, '2026-07-08 06:02:39'),
(3, 3, 'entree', 35.000, NULL, NULL, 'Stock initial', '2026-05-08', NULL, '2026-07-08 06:02:39'),
(4, 4, 'entree', 12.000, NULL, NULL, 'Stock initial', '2026-05-08', NULL, '2026-07-08 06:02:39'),
(5, 5, 'entree', 4000.000, NULL, NULL, 'Stock initial', '2026-05-08', NULL, '2026-07-08 06:02:39'),
(6, 6, 'entree', 800.000, NULL, NULL, 'Stock initial', '2026-05-08', NULL, '2026-07-08 06:02:39'),
(7, 1, 'entree', 100.000, 1, 1, 'Reception BC-2026-001', '2026-02-06', NULL, '2026-07-08 06:02:39'),
(8, 3, 'entree', 15.000, 1, 1, 'Reception BC-2026-001', '2026-02-06', NULL, '2026-07-08 06:02:39'),
(9, 1, 'entree', 120.000, 2, 2, 'Reception BC-2026-002', '2026-03-06', NULL, '2026-07-08 06:02:39'),
(10, 3, 'entree', 15.000, 2, 2, 'Reception BC-2026-002', '2026-03-06', NULL, '2026-07-08 06:02:39'),
(11, 1, 'entree', 140.000, 3, 3, 'Reception BC-2026-003', '2026-04-06', NULL, '2026-07-08 06:02:39'),
(12, 3, 'entree', 15.000, 3, 3, 'Reception BC-2026-003', '2026-04-06', NULL, '2026-07-08 06:02:39'),
(13, 1, 'entree', 160.000, 4, 4, 'Reception BC-2026-004', '2026-05-06', NULL, '2026-07-08 06:02:39'),
(14, 3, 'entree', 15.000, 4, 4, 'Reception BC-2026-004', '2026-05-06', NULL, '2026-07-08 06:02:39'),
(15, 1, 'entree', 180.000, 5, 5, 'Reception BC-2026-005', '2026-06-06', NULL, '2026-07-08 06:02:39'),
(16, 3, 'entree', 15.000, 5, 5, 'Reception BC-2026-005', '2026-06-06', NULL, '2026-07-08 06:02:39'),
(17, 4, 'entree', 10.000, NULL, NULL, 'Sortie manuelle', '2026-10-08', 8, '2026-10-08 13:17:55'),
(18, 1, 'entree', 1.000, NULL, NULL, 'Test automate', '2026-10-09', 5, '2026-10-09 13:54:46'),
(19, 1, 'sortie', 1.000, NULL, NULL, 'Annulation test', '2026-10-09', 5, '2026-10-09 13:54:46'),
(20, 6, 'entree', 10.000, 5, 7, 'Reception achat QA-BC-1', '2026-10-01', 9, '2026-10-12 20:41:26'),
(21, 6, 'ajustement', 5.000, NULL, NULL, 'QA', '2026-10-12', 9, '2026-10-12 20:41:26');

-- --------------------------------------------------------

--
-- Structure de la table `paiements`
--

CREATE TABLE `paiements` (
  `id` int(10) UNSIGNED NOT NULL,
  `facture_id` int(10) UNSIGNED NOT NULL,
  `date_paiement` date DEFAULT NULL,
  `montant` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `mode` enum('especes','cheque','virement','mobile_money','autre') NOT NULL DEFAULT 'especes',
  `reference_paiement` varchar(80) DEFAULT NULL,
  `cree_par` int(10) UNSIGNED DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `paiements`
--

INSERT INTO `paiements` (`id`, `facture_id`, `date_paiement`, `montant`, `mode`, `reference_paiement`, `cree_par`, `cree_le`) VALUES
(1, 1, '2026-02-19', 36000000, 'virement', NULL, 6, '2026-07-08 06:02:39'),
(2, 2, '2026-03-19', 45600000, 'virement', NULL, 6, '2026-07-08 06:02:39'),
(3, 3, '2026-04-19', 55200000, 'virement', NULL, 6, '2026-07-08 06:02:39'),
(4, 4, '2026-05-19', 64800000, 'virement', NULL, 6, '2026-07-08 06:02:39'),
(5, 5, '2026-06-19', 44640000, 'virement', NULL, 6, '2026-07-08 06:02:39'),
(6, 6, '2026-07-19', 50400000, 'virement', NULL, 6, '2026-07-08 06:02:39'),
(7, 1, '2026-10-02', 1000, 'especes', NULL, 5, '2026-10-02 14:28:11'),
(9, 6, '2026-10-13', 33600000, 'especes', NULL, 7, '2026-10-13 06:13:26'),
(10, 7, '2026-10-14', 10000000, 'especes', NULL, 5, '2026-10-14 20:30:41');

-- --------------------------------------------------------

--
-- Structure de la table `parametres`
--

CREATE TABLE `parametres` (
  `id` int(10) UNSIGNED NOT NULL,
  `cle` varchar(100) NOT NULL,
  `valeur` text DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `parametres`
--

INSERT INTO `parametres` (`id`, `cle`, `valeur`, `description`, `cree_le`, `modifie_le`) VALUES
(1, 'devise', 'Ar', 'Symbole de la devise (Ariary)', '2026-07-07 17:51:43', '2026-07-07 17:51:43'),
(2, 'entreprise_nom', 'BTP Boeny Construction', 'Nom de l\'entreprise', '2026-07-07 17:51:43', '2026-07-08 07:13:15'),
(3, 'entreprise_ville', 'Mahajanga', 'Ville du siege', '2026-07-07 17:51:43', '2026-07-07 17:51:43'),
(4, 'demo_charge', '1', 'Jeu de donnees de demonstration charge', '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 'entreprise_adresse', 'Lot II M 45 Mahajanga', NULL, '2026-07-08 07:13:15', '2026-07-08 07:13:15'),
(7, 'entreprise_telephone', '032 11 222 33', NULL, '2026-07-08 07:13:15', '2026-07-08 07:13:15'),
(8, 'entreprise_email', 'contact@btpboeny.mg', NULL, '2026-07-08 07:13:15', '2026-07-08 07:13:15'),
(9, 'entreprise_nif', '4001234567', NULL, '2026-07-08 07:13:15', '2026-07-08 07:13:15'),
(10, 'entreprise_stat', '41200 11 2020 0 12345', NULL, '2026-07-08 07:13:15', '2026-07-08 07:13:15'),
(11, 'entreprise_logo', 'uploads/logo-6055aeee2f77.png', NULL, '2026-07-08 07:13:43', '2026-10-14 19:55:02');

-- --------------------------------------------------------

--
-- Structure de la table `pointages`
--

CREATE TABLE `pointages` (
  `id` int(10) UNSIGNED NOT NULL,
  `chantier_id` int(10) UNSIGNED NOT NULL,
  `lot_id` int(10) UNSIGNED DEFAULT NULL,
  `employe_id` int(10) UNSIGNED NOT NULL,
  `date_pointage` date NOT NULL,
  `type_presence` enum('journee','demi_journee','absent') NOT NULL DEFAULT 'journee',
  `cout` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `commentaire` varchar(255) DEFAULT NULL,
  `cree_par` int(10) UNSIGNED DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `pointages`
--

INSERT INTO `pointages` (`id`, `chantier_id`, `lot_id`, `employe_id`, `date_pointage`, `type_presence`, `cout`, `commentaire`, `cree_par`, `cree_le`, `modifie_le`) VALUES
(1, 1, NULL, 2, '2026-07-08', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(2, 1, NULL, 3, '2026-07-08', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(3, 1, NULL, 4, '2026-07-08', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(4, 1, NULL, 2, '2026-07-07', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(5, 1, NULL, 3, '2026-07-07', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(6, 1, NULL, 4, '2026-07-07', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(7, 1, NULL, 2, '2026-07-06', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(8, 1, NULL, 3, '2026-07-06', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(9, 1, NULL, 4, '2026-07-06', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(10, 1, NULL, 2, '2026-07-05', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(11, 1, NULL, 3, '2026-07-05', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(12, 1, NULL, 4, '2026-07-05', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(13, 1, NULL, 2, '2026-07-04', 'demi_journee', 12500, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(14, 1, NULL, 3, '2026-07-04', 'demi_journee', 9000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(15, 1, NULL, 4, '2026-07-04', 'demi_journee', 11000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(16, 1, NULL, 2, '2026-07-03', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(17, 1, NULL, 3, '2026-07-03', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(18, 1, NULL, 4, '2026-07-03', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(19, 1, NULL, 2, '2026-07-02', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(20, 1, NULL, 3, '2026-07-02', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(21, 1, NULL, 4, '2026-07-02', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(22, 1, NULL, 2, '2026-07-01', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(23, 1, NULL, 3, '2026-07-01', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(24, 1, NULL, 4, '2026-07-01', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(25, 1, NULL, 2, '2026-06-30', 'journee', 25000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(26, 1, NULL, 3, '2026-06-30', 'journee', 18000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(27, 1, NULL, 4, '2026-06-30', 'journee', 22000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(28, 1, NULL, 2, '2026-06-29', 'demi_journee', 12500, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(29, 1, NULL, 3, '2026-06-29', 'demi_journee', 9000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(30, 1, NULL, 4, '2026-06-29', 'demi_journee', 11000, NULL, 6, '2026-07-08 06:02:39', '2026-07-08 06:02:39'),
(31, 6, NULL, 6, '2026-10-01', 'journee', 18000, NULL, 9, '2026-10-12 20:41:26', '2026-10-12 20:41:26');

-- --------------------------------------------------------

--
-- Structure de la table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expire_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `revoque` tinyint(1) NOT NULL DEFAULT 0,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`id`, `utilisateur_id`, `token_hash`, `expire_le`, `revoque`, `cree_le`) VALUES
(61, 5, 'd11e576d894de6d713898a50477d19ebfeb5c46891e4d0ecd0343214c8db588f', '2026-07-15 02:52:20', 0, '2026-07-08 02:52:20'),
(62, 5, '2e1bc76a59c11881a4ea2ac5b12187fba29fa99762e614987ea35a8819989eeb', '2026-07-08 05:55:38', 1, '2026-07-08 05:55:38'),
(63, 5, '43138a172489822a0d64d338a72af6f570b9afeb63a1d9457416ecfd6bf2a15c', '2026-07-08 05:55:49', 1, '2026-07-08 05:55:38'),
(64, 5, 'e635abf08450ec677b906f563f660fe58b95d310fc51cfe7c331b1c63f149ecd', '2026-07-08 05:55:50', 1, '2026-07-08 05:55:49'),
(65, 5, 'c9d7e64d29fca8ae893285d604dd6b9c60224ef532fd282ec353a981d378677c', '2026-07-08 05:55:51', 1, '2026-07-08 05:55:50'),
(66, 5, '9ee777c9fcf6f21237ce97ea3798019678dd29c14c2b0fa8dc1090ca08608604', '2026-07-08 05:55:52', 1, '2026-07-08 05:55:51'),
(67, 5, 'f8c10e598843db8e380fa873e2aed559839b0dcac6c90c6728704b4c759d20d0', '2026-07-08 05:55:57', 1, '2026-07-08 05:55:52'),
(68, 5, '8778a1766d82a976bde88c2efdae2386b6fee5b603cb61db29722dd92d89b493', '2026-07-08 05:55:59', 1, '2026-07-08 05:55:57'),
(69, 5, '36c19d693552ca3208aae06e9f2887ea708ea3c1521cc4a1697908f49d85af05', '2026-07-08 05:56:01', 1, '2026-07-08 05:55:59'),
(70, 5, '75a068cd7c5f72ea916bd434dbad73861aa8db80512439bc588c96d52ee5789b', '2026-07-08 05:56:02', 1, '2026-07-08 05:56:01'),
(71, 5, '6f3e1c697d41eb43108e1ebe279104f711287e5847176d8963f63185d0b9225a', '2026-07-08 05:56:03', 1, '2026-07-08 05:56:02'),
(72, 5, '1c1de6e84e23a3318996390ac695810df6b7eaac3a36a4660eb3023f43f62da7', '2026-07-08 05:56:04', 1, '2026-07-08 05:56:03'),
(73, 5, '4c7fc75d48ac8ab965293cef9e82aaa3591bc8a05fca7d3d2f61d5c965640328', '2026-07-08 05:56:05', 1, '2026-07-08 05:56:04'),
(74, 5, 'eb6c542125f2af99e5aed4d3a20afda6f7ffbd386f924e8be1eb11cffbb14f19', '2026-07-08 05:56:06', 1, '2026-07-08 05:56:05'),
(75, 5, '231205656fb67c0a76ae1183d6cb2d1d48b8ca1f28f32d362343226cf13bc7a9', '2026-07-08 05:56:08', 1, '2026-07-08 05:56:06'),
(76, 5, '65090d16f4a8d4d9d921f88d452e9bb47588e342b94fcc6a7c211337908ce2a3', '2026-07-08 05:56:10', 1, '2026-07-08 05:56:08'),
(77, 5, 'a5b918b7a928e5a96b7da5a3d88b2891c1fa6b8a5a0b84599db576bc8acc2553', '2026-07-08 05:56:13', 1, '2026-07-08 05:56:10'),
(78, 5, '0c12409f9b2b897a22f7670b9391551a3c259b979b085f52ed490637a811b1de', '2026-07-08 05:56:14', 1, '2026-07-08 05:56:13'),
(79, 5, '55c8effb45c025528704712bfd77c49573f70c9512a5aea08e61fcc008a585ed', '2026-07-08 05:56:20', 1, '2026-07-08 05:56:14'),
(80, 5, 'c835de06343d06789be9ba18b0b3c0e00c1b43602e192381ab98a3f0c1fa9504', '2026-07-08 05:56:21', 1, '2026-07-08 05:56:20'),
(81, 5, '1a0165fd6edb503f6624f4516146cfab1a81b57f966b57094c7df8676d1850fb', '2026-07-08 05:56:23', 1, '2026-07-08 05:56:21'),
(82, 5, 'b808c71d4688cd091bfa093574c449ab880984298ed69da97213585d56445dbe', '2026-07-08 06:04:58', 1, '2026-07-08 05:56:23'),
(83, 5, 'dcd0c0f9e13c82d334e40874970e78160e10dac0bb58c8df8752137e6546f780', '2026-07-15 06:03:39', 0, '2026-07-08 06:03:39'),
(84, 5, '1cd1dfc35ac756c7628051ee62b6bc574b18ebfa7687578fd98447e72ad3a58d', '2026-07-08 06:04:17', 1, '2026-07-08 06:04:16'),
(85, 5, 'a543701a485d55540c270b42c750d1868c4be2a1d1f7f033051c0db76e479a29', '2026-07-15 06:04:17', 0, '2026-07-08 06:04:17'),
(86, 5, '10d916d0d953587acf7d0308ccf6cd9c59032e1faff74776a075c732bedc2834', '2026-07-08 06:05:01', 1, '2026-07-08 06:04:58'),
(87, 5, 'c5c553b4f0512cb74440fc59b336126d41d389ca81bc76e1c110d19538320e6f', '2026-07-08 06:05:06', 1, '2026-07-08 06:05:01'),
(88, 5, '37fe755583568ae3d9ea804c7561b90e0827d1a5fe5bb80c0396e971ae71b912', '2026-07-08 06:05:07', 1, '2026-07-08 06:05:06'),
(89, 5, '11687fc663dc3fb901d6be7ec95c11cb8de2e326b6f1ec2499ecf3a1112440de', '2026-07-08 06:05:11', 1, '2026-07-08 06:05:07'),
(90, 5, 'e6a8d9c1e70476da00a08f2128c2e3dfeb310d1c8befe2b659ee6a6c476d002b', '2026-07-08 06:05:13', 1, '2026-07-08 06:05:11'),
(91, 5, 'ab5f3b82db2903c6c3dbaf6eafcc2c1d68822a7e95324876cfad872e6ec5c062', '2026-07-08 06:05:14', 1, '2026-07-08 06:05:13'),
(92, 5, 'c4e1fc164cabc50a318b75b9aa5799213d87eb0d57ae35aa46f1c396ac8f1138', '2026-07-08 06:05:16', 1, '2026-07-08 06:05:14'),
(93, 5, 'b8711e5b10c6f7f9fa9ecf63c2785c41823c00543ea318af6f6e18ac8a0c518e', '2026-07-08 06:05:17', 1, '2026-07-08 06:05:16'),
(94, 5, '927c6f5b6571f89a950425949236d935be07d9b7d6d4629ce7dfb1b7774ac5d2', '2026-07-08 06:05:18', 1, '2026-07-08 06:05:17'),
(95, 5, 'b15e2977aae5b12eb12ab353995ba958abcdd808ee69a000ea029bf834d5feaf', '2026-07-08 06:05:19', 1, '2026-07-08 06:05:18'),
(96, 5, 'c870d5ad7cf2bb1c781dbd5563267fa91512909aa6e45c9ea9fa40784034d183', '2026-07-08 06:05:21', 1, '2026-07-08 06:05:19'),
(97, 5, '817ee5b294b93e248f783bf9e2e6ff540b78f3c193a844eff81189356ec980a8', '2026-07-08 06:05:22', 1, '2026-07-08 06:05:21'),
(98, 5, 'f0fefdca1e842ee8ce3702fd36797087e6b0498e0dc88d24b12033cd7ccb1312', '2026-07-08 06:05:30', 1, '2026-07-08 06:05:22'),
(99, 5, 'f941ed023052b6de19e54abb941e678b5417f9a5389cb92b75f12c9b268b105b', '2026-07-08 06:05:31', 1, '2026-07-08 06:05:30'),
(100, 5, 'ed15a9aaee45f661602019a8ce73363bcea8dfe183dd63feec3226638af1abc7', '2026-07-08 06:05:33', 1, '2026-07-08 06:05:31'),
(101, 5, '69ef249251aee160ccb3ba229ff3a1a36a95ac0037f7ccbd296664b5450563e8', '2026-07-08 06:05:34', 1, '2026-07-08 06:05:33'),
(102, 5, '2fe1f60a5f18195aad5cc7f9105d720a4e70b7cf1f424b540e01fa647eabb0b2', '2026-07-08 06:05:36', 1, '2026-07-08 06:05:34'),
(103, 5, 'a058a36619cde5ec8f1c9a5446b56befdebf058a8ce54a769303cd21537f2394', '2026-07-08 06:05:37', 1, '2026-07-08 06:05:36'),
(104, 5, 'abb107c285cc9ead23e96d1fbc1cb9e56b40c469143bad4b7330b1c6f4a2632c', '2026-07-08 06:05:40', 1, '2026-07-08 06:05:37'),
(105, 5, 'fcdc9b15d7dbb66c63065178ec445d0231094aa4ce7a52950c18cad7d72d6109', '2026-07-08 06:05:41', 1, '2026-07-08 06:05:40'),
(106, 5, '75bbf1fbf18d27f3a1ba6f978e20ffcd9eb5c3be8bbb48fe455251010b0810f7', '2026-07-08 06:07:47', 1, '2026-07-08 06:05:41'),
(107, 5, '5ec0dd2bd5f00f434681e15636f7f0b0352b5762b082915734ed7d08f905339f', '2026-07-15 06:06:06', 0, '2026-07-08 06:06:06'),
(108, 5, 'bc57617fccfa441de8ac07a7c683722ef5e626e5ba2c75503c2bf867367da93b', '2026-07-08 06:06:11', 1, '2026-07-08 06:06:09'),
(109, 5, 'a367d2e2bac2b81be97ab14cab0daca85582e151c13d6b1562586236200fcb4c', '2026-07-15 06:06:11', 0, '2026-07-08 06:06:11'),
(110, 5, '4596e97d7ba78f3fa6ad4e99936d71dcd236b35c02a9a7879f3bd443e59b844f', '2026-07-08 06:07:49', 1, '2026-07-08 06:07:47'),
(111, 5, '576bd0869906122272623020d98454f9143e7de39f66bedd5a11e63c1c899013', '2026-07-08 06:07:50', 1, '2026-07-08 06:07:49'),
(112, 5, 'c868359bef642183184b9cf67502b516fda33fa7f8eed95276d987207d214ac3', '2026-07-08 06:07:51', 1, '2026-07-08 06:07:50'),
(113, 5, 'f1bd9331900df95e376fca035719f1791cb335608a2b7b92869cee73ea278062', '2026-07-08 06:07:51', 1, '2026-07-08 06:07:51'),
(114, 5, '0ee29c15a09d8e12b31941d444728cc5f1eafe9adca82131af3dd7d91e1f5792', '2026-07-08 06:07:53', 1, '2026-07-08 06:07:51'),
(115, 5, 'b79ec761c1ac52967f1a8a1ab74f82b82a8eb6f6f889cc2a9c49679ad94b0918', '2026-07-08 06:07:54', 1, '2026-07-08 06:07:53'),
(116, 5, '998594e473c49592d298616822117eff308c4103c34182cbde8ae1d39c5ee3f3', '2026-07-08 06:07:55', 1, '2026-07-08 06:07:54'),
(117, 5, '0374f26ddf3ded93f37e7368b6f52a6c2114969d35152cd4e6c8c6f4f8c7d5e3', '2026-07-08 06:07:55', 1, '2026-07-08 06:07:55'),
(118, 5, '5d590575eb52fdb58bf65cb264b23b8df7df52e92733f764f4196c3fdee6f716', '2026-07-08 06:36:36', 1, '2026-07-08 06:07:55'),
(119, 5, '2f128e91b16732b874f8619d7e12d29127a7219a2f6f4accf629c4c37991ba79', '2026-07-08 06:08:13', 1, '2026-07-08 06:08:12'),
(120, 5, 'bfe572f11503b6e0d66b96c8d205022a9062dd4d94362d96c017f9a4fb81da96', '2026-07-15 06:08:13', 0, '2026-07-08 06:08:13'),
(121, 5, '92de43c4f3af67f21d4555e10bcd13246a26048ffdeca54b946c57d6b37168be', '2026-07-08 06:56:49', 1, '2026-07-08 06:36:36'),
(122, 5, '60b9c769fc9fc730c03e15089739449e49256a3726ea50aca8ce33062f4faf80', '2026-07-08 06:40:50', 1, '2026-07-08 06:40:49'),
(123, 5, '70c25ec51c779ff907ab213a304457b0d61731f330dfc2d74a16e4e28410e67e', '2026-07-15 06:40:50', 0, '2026-07-08 06:40:50'),
(124, 5, '8272353d0df0e9088712022e6b2e7d4a3d7d8059bc5f910ab0e3e26e7f763976', '2026-07-08 06:56:50', 1, '2026-07-08 06:56:49'),
(125, 5, 'ec129eef770dc55253943ae7e4997f05add3e500ea7a3b67cafee0b978016313', '2026-07-08 06:56:51', 1, '2026-07-08 06:56:50'),
(126, 5, 'b4f9a0489c4b52e8115e792382085f6570ba792a087fdd8ff9f84bd1eafd69c3', '2026-07-08 06:56:51', 1, '2026-07-08 06:56:51'),
(127, 5, '99e65ed9972a7f77e7085f3ad725ae0352e6c57b74ff3b651d1a5ab02e7f6913', '2026-07-08 06:59:25', 1, '2026-07-08 06:56:51'),
(128, 5, '39ee1b6028113cf4860dcea2920b02277922b18b81bf59f92f2b328ce280d59c', '2026-07-08 06:59:29', 1, '2026-07-08 06:59:25'),
(129, 5, '25cd0c561d4337cf6421552452cd013ff737af1e36178a1fe6e714338f6c6dd2', '2026-07-08 06:59:34', 1, '2026-07-08 06:59:30'),
(130, 5, '9c81ca97d87a90c55ba9b0ec6e9519731ef2c4ce8676157530b3b6299c59ebf0', '2026-07-08 06:59:42', 1, '2026-07-08 06:59:34'),
(131, 5, 'dbd8656d248c516d9c6d448a4ce0b4280ea8e0d86091921d0ece8eaf8254956c', '2026-07-08 06:59:49', 1, '2026-07-08 06:59:42'),
(132, 5, '927d533432db7c0aec25c5368c1e2d717f424c2131eb542421966da0f69a7d26', '2026-07-08 07:05:39', 1, '2026-07-08 06:59:49'),
(133, 5, '68a4fb7ec7da65d31d0f7644bcf0d7377d958293755d89444caba82828a8ebb4', '2026-07-08 07:05:40', 1, '2026-07-08 07:05:39'),
(134, 5, '7e05ac74aef9f0742901cca3daa8742850ed840636eb598d47b52b9cc782f764', '2026-07-08 07:05:41', 1, '2026-07-08 07:05:40'),
(135, 5, 'c0bfba74b4e10638660a74dad376c3f6d6e30a53fae2f3b17b62e417e5b4aa4d', '2026-07-08 07:11:35', 1, '2026-07-08 07:05:41'),
(136, 5, 'a0b2b3432da64460d914281985814c141ef4815da6fa46b60f90235ae511565c', '2026-07-08 07:11:36', 1, '2026-07-08 07:11:35'),
(137, 5, '18616f79d92f959895148998c03f64461c6e3beed82ad703768ce5215d0de209', '2026-07-08 07:11:37', 1, '2026-07-08 07:11:36'),
(138, 5, '6900a317b89f8ba0c02bd48162cde24e14e73fe8deb6c6a382bc817b3dc5f4fd', '2026-07-08 07:11:38', 1, '2026-07-08 07:11:37'),
(139, 5, '796936057301d2f068421a6a6fa7ca8ebc63204cd54e62042aaf6da5b349dbff', '2026-07-08 07:11:39', 1, '2026-07-08 07:11:38'),
(140, 5, 'ec06239a925d6705a276a8caa4fb8b96615726323880647c5160ca49c3d87a4a', '2026-07-08 07:11:39', 1, '2026-07-08 07:11:39'),
(141, 5, '8aa64dce2baf3b73098b766d531174b5a8152d99b33d4b10fc6a984bc812a498', '2026-07-08 07:11:40', 1, '2026-07-08 07:11:39'),
(142, 5, '821c48201daa7970cf1bf4e6b451d84c2d502db056aefa1437bfc866c75b3759', '2026-07-08 07:11:41', 1, '2026-07-08 07:11:40'),
(143, 5, '04b6830d96dfd4693dee3f6d76170427303257edeb2c0fa10ea092f2c326e41a', '2026-07-08 07:11:42', 1, '2026-07-08 07:11:41'),
(144, 5, 'b113d206aced90d35563ee17f1528efa98f6f9deb068584b99d145e00cb71c5f', '2026-07-08 07:11:42', 1, '2026-07-08 07:11:42'),
(145, 5, '30b5bc8db37ee7905d97483d6698640424f0c6e6c4f4189363346c0ae8058431', '2026-07-08 07:11:43', 1, '2026-07-08 07:11:42'),
(146, 5, '75dd497abb942bb15f14c7182a99c14d41325d8251e26728a0dfe5cd78b16c0d', '2026-07-08 07:24:26', 1, '2026-07-08 07:11:43'),
(147, 5, '84bdb59cef386228fbfbc113f1fef4b370365399d93cd2ab19cba246cabf06ed', '2026-07-15 07:13:15', 0, '2026-07-08 07:13:15'),
(148, 8, '3ecadb5ad80e23c7aada76db96ced54fa8c7cd32059fe5e0821b288c1bbba107', '2026-09-28 11:54:12', 1, '2026-07-08 07:13:16'),
(149, 5, 'e65636b30ff90fea54c05f0d04ba3f1ff4135364fb3355c0ef48019e7cf458ed', '2026-07-15 07:13:43', 0, '2026-07-08 07:13:43'),
(150, 5, 'c66223855a4d6e14f1ff751bac3be83752f6dc3e135fe5a9677834accdef4e9f', '2026-07-15 07:14:15', 0, '2026-07-08 07:14:15'),
(151, 5, 'f216a1196207af3611a3d40d6fe4c8d4ab5c21fb6d85b4a64b215c6f1836bb0c', '2026-07-08 07:14:26', 1, '2026-07-08 07:14:25'),
(152, 5, '0bfe933a7ea11396e4e9848410947e55e98223856bc9a19fd0e99f2842f05ed4', '2026-07-15 07:14:26', 0, '2026-07-08 07:14:26'),
(153, 5, '88400cc5975c94fb26d813f4c8b2b61f2b46eb78857496d0ab2431f61a7fe87a', '2026-07-08 07:24:31', 1, '2026-07-08 07:24:26'),
(154, 5, '6d640058f0daab7e11be1c54a324f73ddb3df64d536d398330d9f9ca56360e34', '2026-07-08 07:24:34', 1, '2026-07-08 07:24:31'),
(155, 5, '0dbda815d95965257e1fba06006889ced39a68cd6ffe13306aed8d8df892d007', '2026-07-08 07:24:35', 1, '2026-07-08 07:24:34'),
(156, 5, '4a8c8801da2b5867ca0b5a3f5f87e6635aad6bb51015fa2d8aedbe5c908fc9cb', '2026-07-08 07:24:36', 1, '2026-07-08 07:24:35'),
(157, 5, '43b97165be6de48accc421dd8561cb16029346617d46072288c64f81fd79d936', '2026-07-08 07:24:40', 1, '2026-07-08 07:24:36'),
(158, 5, '2df053a12dd378f2447fb3509890fb1cec5043adc830a3b5eb8add4b5521176e', '2026-07-08 07:24:41', 1, '2026-07-08 07:24:40'),
(159, 5, '9295ae975588797c4f2303e57e21c75e794c04eab7ac00b3f0dea9e41751aa11', '2026-07-08 07:24:43', 1, '2026-07-08 07:24:41'),
(160, 5, 'de500800315f64f3e791d519db880d8135b4db511fae11b716926eed7416b90f', '2026-07-08 07:24:44', 1, '2026-07-08 07:24:43'),
(161, 5, '8faa78ae98171131f9d643c47781b8a1c99fc2826597e9ac50b976bfd66781e1', '2026-07-08 07:24:45', 1, '2026-07-08 07:24:44'),
(162, 5, '938cb9993e899d2024a1a2215510eba17bec714399a1e9ab0bcbe6b365fddf12', '2026-07-08 07:24:46', 1, '2026-07-08 07:24:45'),
(163, 5, '82aa684ed5c9b9672332e82f0abed8c0ca9486b84d31634e06f8ae9aadbeaf4d', '2026-07-08 07:24:47', 1, '2026-07-08 07:24:46'),
(164, 5, '031701225d16c7226852cb8464200746608664e630a1147233444cc7d181ea88', '2026-07-08 08:03:19', 1, '2026-07-08 07:24:47'),
(165, 5, '2578e9cf8e8c71fcb8a460eb3cd9d7966191c3988d4840f3e67cd606e090146d', '2026-07-08 07:44:04', 1, '2026-07-08 07:44:03'),
(166, 5, '9f60bd263ddaf6cbcde9d007f5b7daee9b73d325fbdd5edb1fc76912cc3ce055', '2026-07-15 07:44:04', 0, '2026-07-08 07:44:04'),
(167, 5, '0bc3c42d00b38856adbb069e98b971645719afdde6e965108662101367c3533a', '2026-07-08 07:44:08', 1, '2026-07-08 07:44:07'),
(168, 5, '3fe952a312005ec9abdd20261609f08161532b833ccb23804216c82942f070b2', '2026-07-15 07:44:08', 0, '2026-07-08 07:44:08'),
(169, 5, '3287db02bfede70f9da218e7d48feb60be8c3b76f93208d8c1e5eb2933a73479', '2026-07-08 07:46:48', 1, '2026-07-08 07:46:47'),
(170, 5, '5570588080c3d62c06158bfa5a73ad04600f17c4bfa58b7dc59e32a93b772b35', '2026-07-15 07:46:48', 0, '2026-07-08 07:46:48'),
(171, 5, 'cfdce93b29114df700afc070c3c7e6ee39ba88b23d3c5034b8bcb13954763310', '2026-07-08 07:47:07', 1, '2026-07-08 07:47:05'),
(172, 5, '48aeb5ec240604f214d6692cae9bb90ecc3a2602b296cd46c38b7b4e66a7b7fc', '2026-07-15 07:47:07', 0, '2026-07-08 07:47:07'),
(173, 5, 'fad7f70f980e555619c84b823dac093c4516b797aab0c0e9e5b65a2ab6066c49', '2026-07-08 08:03:24', 1, '2026-07-08 08:03:19'),
(174, 5, 'e7dabf9fa352225c142e0143454f37721b8692e5fc6b8ba693c425101e4dd9e9', '2026-07-08 08:03:34', 1, '2026-07-08 08:03:24'),
(175, 5, '62a46af2a7ebbf798a907aae17414681dff64a1506638b61494fabbc99843b3f', '2026-07-08 08:03:34', 1, '2026-07-08 08:03:34'),
(176, 5, 'f2375c2934b542ebd5e28c8502369d1ae5771f893d9c797c89f145fe2ec23fe9', '2026-07-08 08:03:38', 1, '2026-07-08 08:03:34'),
(177, 5, '1fff9169106987a81253c08f30a601c42c92de461a6aaf3a2a7ff9d20d21d7fc', '2026-07-08 08:03:39', 1, '2026-07-08 08:03:38'),
(178, 5, '6e382cf84abeb114e15ffe410444e964b1d0aa8590abf9af66a0f41a98f04cf1', '2026-07-08 08:03:41', 1, '2026-07-08 08:03:39'),
(179, 5, 'cddcde14d7cc597f2d7584edc4fa0a0809271d10afc8d7e7fb17b359f12d503e', '2026-07-08 08:03:41', 1, '2026-07-08 08:03:41'),
(180, 5, '620113f533b16f26a20cfd58d7ad768270c1d47ee7fe0f50fedb62bffa508693', '2026-07-08 08:03:43', 1, '2026-07-08 08:03:41'),
(181, 5, '85643d59a703ca5c4a60e88040098d4d9d37ed335a59ab06fba620b30b596283', '2026-07-08 08:03:43', 1, '2026-07-08 08:03:43'),
(182, 5, 'c88c83b220e39c983d4babde4bfdf6239aa1aaedcade9074cd8baab0122d488d', '2026-07-08 08:03:44', 1, '2026-07-08 08:03:43'),
(183, 5, 'c1d89c1c8f9bc5b682a94aab12850d5d8a8abbd3be6fe2089f7cdb2be47dea36', '2026-07-08 08:03:50', 1, '2026-07-08 08:03:44'),
(184, 5, '5af26d1b935bdb1736d02e7866a4a0eeca4fe66d35f0911bc869fedd93023bba', '2026-07-08 08:03:53', 1, '2026-07-08 08:03:50'),
(185, 5, 'e671d18818d5c8d04419fca5b7bd4128a2c691407ed06fc6e4142b0493616740', '2026-07-08 08:03:54', 1, '2026-07-08 08:03:53'),
(186, 5, '1e9cc5468d155cb238a3ee04e31cf95f1bb9fe26d6b6bc294cc4aec528fad8dd', '2026-07-08 08:07:50', 1, '2026-07-08 08:03:54'),
(187, 5, 'a7e03a055589d65c014e4ceb9fef0286f49e57552de4e62e2fce38d0c823252b', '2026-07-08 08:06:45', 1, '2026-07-08 08:06:44'),
(188, 5, '15027a3850fb97e43f375901030401efc0c7567d53b9ec9dab82cdf3f0aed303', '2026-07-15 08:06:45', 0, '2026-07-08 08:06:45'),
(189, 5, 'de315653fbf238e0fff94ae19a15a24552838ef99c2113a7bf2fad0dc1614411', '2026-07-08 08:07:54', 1, '2026-07-08 08:07:50'),
(190, 5, 'be8454068572d730730d45b521935eece5effd4f387a272c26f13fcca2ba80b5', '2026-07-08 08:07:55', 1, '2026-07-08 08:07:54'),
(191, 5, '66bf73932c03743b433053507c20019e53417684502fefadf57e93e6745277c9', '2026-07-08 08:07:56', 1, '2026-07-08 08:07:55'),
(192, 5, 'e209f7d7abeaf99783e0ef0df0dedcc8883e857b81948761221c6379f21d466d', '2026-07-08 08:07:57', 1, '2026-07-08 08:07:56'),
(193, 5, 'c91291186b129c475615eec5e941b2947520d01a3b197bef90146c4c86e42e80', '2026-07-08 08:07:58', 1, '2026-07-08 08:07:57'),
(194, 5, '42f8caa756e5e083b03fbe6111ae94cd1ad1fb41ad2492711a1735215e17afcf', '2026-07-08 08:07:58', 1, '2026-07-08 08:07:58'),
(195, 5, '3061adeeeb9930c10678d30712f7e0f3abedbfc4b09a94fde2c77d4d4b318a54', '2026-07-08 08:07:59', 1, '2026-07-08 08:07:58'),
(196, 5, '8f9b71592a342762773c6f372957cd8d59f223307df56c855ee8aac53f72c40d', '2026-07-08 08:08:00', 1, '2026-07-08 08:07:59'),
(197, 5, 'd76306face76da99226ae9138b427743ae270d38c891ab3c7169573ff3367b05', '2026-07-08 08:08:01', 1, '2026-07-08 08:08:00'),
(198, 5, '7bd09aa3e454dd331db744d703f2e252901bd7d3e053d7885909958c9bdf49b2', '2026-07-08 08:08:01', 1, '2026-07-08 08:08:01'),
(199, 5, '8f0f3c2f3307d60baf6951bbdd46e96254b2b093f0824eb54013d451151cfb23', '2026-07-08 08:08:02', 1, '2026-07-08 08:08:01'),
(200, 5, '77616d55d3525f7c26b5853784b3e333fa5f3f4493134874d08b28d367d1b578', '2026-07-08 08:08:03', 1, '2026-07-08 08:08:02'),
(201, 5, '25ff21e7a34d85ecf55d19b1444e045b7d0623685e4e2be1c412c8414ede1f09', '2026-07-08 08:12:52', 1, '2026-07-08 08:08:03'),
(202, 5, '8f707176b9b2af54d4792e925780da9293a9b7e4d6a18109e2bc97f25e919479', '2026-07-08 08:13:36', 1, '2026-07-08 08:12:52'),
(203, 5, '73adcecf6a441ee9e3eaf70d49d2ab6785e73243bdda9cd742e4e648b593a3f6', '2026-07-08 08:18:46', 1, '2026-07-08 08:13:36'),
(204, 5, 'c6d2e37c6b3147d8aac075ebbc41b0932625e4cabcfbd4ac9630b2bd9d6786e2', '2026-07-08 08:19:05', 1, '2026-07-08 08:18:46'),
(205, 5, 'e4945971acd333c6cf478d158e043a15c6dc3883876835d0fdcc60f80c7b9668', '2026-07-08 08:19:10', 1, '2026-07-08 08:19:05'),
(206, 5, 'fa7b1bedf7d352c10c1b14d43f20224cc017be69fa8918ed2d6a38992d495545', '2026-07-08 08:19:46', 1, '2026-07-08 08:19:10'),
(207, 5, 'f6bd320e911a0209717278fbc5a5c60f36e56ef7e2ab5b5f277c7d8a6ce51240', '2026-07-08 08:19:51', 1, '2026-07-08 08:19:46'),
(208, 5, 'f539e8ef867e324599d15418e887d658d80a36fafc821c481a2adfd166b87f01', '2026-07-08 08:19:56', 1, '2026-07-08 08:19:51'),
(209, 5, 'b371bcbd0cc868b0b3a47edaf72805e4c8304afcff4d372e075f8167d2a73a58', '2026-07-08 08:20:18', 1, '2026-07-08 08:19:56'),
(210, 5, '8e65d19e948a095c06d8ab7e471a7acc0de71cac3aee083803089db5ca02d251', '2026-07-08 08:20:21', 1, '2026-07-08 08:20:18'),
(211, 5, '1cac9569f0b3c0a8ac2707c9bbe87f1eefad1c113f59e5fdd6300ca1850b7d81', '2026-07-08 08:20:29', 1, '2026-07-08 08:20:21'),
(212, 5, '12770bb3c3c95fb5d58b43b75ad3a83192ac8d7d4f72be2107e4fc9b79047d46', '2026-07-08 08:20:34', 1, '2026-07-08 08:20:29'),
(213, 5, 'd4f37d40c4b53bd79048f6b3c7b5ef82d5ff1d389a50e64d66a471b9ebec2a2d', '2026-07-08 08:20:45', 1, '2026-07-08 08:20:34'),
(214, 5, 'b51c628f7acbaeb60b483e0d7a382e5e62953ec645111b52781e8fd19cc25e1a', '2026-07-08 08:20:50', 1, '2026-07-08 08:20:45'),
(215, 5, '6fcbb94ff57c34525412b0f39b8976bc28ad6d482ba4e42eb0ed7d62126c0694', '2026-07-08 08:21:16', 1, '2026-07-08 08:20:50'),
(216, 5, '1692fba7b04aef8e180b8445d13f141bcd163e06ac3d44400f7891488d59f032', '2026-07-08 08:21:25', 1, '2026-07-08 08:21:16'),
(217, 5, '5e59f9784cad86aebfb10a006c9da2f824f8a397d32532026c728e1518eca73a', '2026-07-08 08:21:28', 1, '2026-07-08 08:21:25'),
(218, 5, 'dd43ddd67281bf5d28c1c5bb71e6ff5b325d233a5cdc279c2be1eff68dc01079', '2026-07-08 08:21:30', 1, '2026-07-08 08:21:28'),
(219, 5, '3d2909417ee29824ad5ec4283e83415800cfe449a8dbb79ff84511b683f7c96d', '2026-07-08 08:21:33', 1, '2026-07-08 08:21:30'),
(220, 5, 'a27eaaa798ac3de5cb82b33b44e2eff386b967c18c72ec2eec755f7d355cb055', '2026-07-08 08:21:36', 1, '2026-07-08 08:21:33'),
(221, 5, '50910a6a54f2b09597350f6d912eb81dd88daa1e5fd6a6cdad7b5df99ea4ad17', '2026-07-08 08:21:39', 1, '2026-07-08 08:21:36'),
(222, 5, '668ad4d35463f68f0f21679e1f8b54d5e7eb9318fb6920b5792ef0101fd3950f', '2026-07-08 08:30:40', 1, '2026-07-08 08:21:39'),
(223, 5, '526e5d6c352a81fac247983a95a971bdb6cb2f6b12793923a0cdd7fb0f441480', '2026-07-08 08:33:45', 1, '2026-07-08 08:30:40'),
(224, 5, '8a0e8c319f3ffc0b0d9303ea6e7db496c5db4bfd12864cdf02d71a5c7200f2a9', '2026-07-08 16:20:02', 1, '2026-07-08 08:33:45'),
(225, 5, 'b55a4d72289fa353318d2510514bc5bb38a91160a907114559ab33c7b6c3ad1c', '2026-07-09 10:49:03', 1, '2026-07-08 16:20:02'),
(226, 5, '288f46f48ea151a2e34c082e482fd94cd1ccc3779f345422be137a8720df64a6', '2026-07-09 10:49:06', 1, '2026-07-09 10:49:03'),
(227, 5, '19b0927738536c43543079a74732074e871736a4f26a12db4a40acb9e3cac846', '2026-07-16 10:49:06', 0, '2026-07-09 10:49:06'),
(228, 5, 'ff2512c6b7d0af11eb57613e13c7047f2ada1e633be55c489a991c529bd877df', '2026-09-18 07:44:45', 1, '2026-09-18 07:44:45'),
(229, 5, 'a2d59459304142efaae035e19d34a95bf375b932d9c055ef1a41f3785ba46b88', '2026-09-18 07:44:45', 1, '2026-09-18 07:44:45'),
(230, 5, 'c78a61e06bf30bace6b110cf16d75a9ca8c36b3c0a11a8f7aab6a5e5ea1941e5', '2026-09-18 07:44:45', 1, '2026-09-18 07:44:45'),
(231, 5, 'c2acbc0cabf3a2f44c8d037672507b79353a31786064b38bc99cc8bae4e64452', '2026-09-18 07:44:52', 1, '2026-09-18 07:44:45'),
(232, 5, '65a7ea0870e15132549e81a6b0691cb54864d8b45d1062a17fbc79c385f0223a', '2026-09-18 07:44:53', 1, '2026-09-18 07:44:52'),
(233, 5, '406f3c49209025e9a71b7f7fd1668e0027def9a73ee9ebd058b2fe73fc307062', '2026-09-18 07:44:56', 1, '2026-09-18 07:44:53'),
(234, 5, 'd6cdd4e013e08abe2f45d7fc05e1c6f21ae874f2869a8b5bc7932dfabe49f3f7', '2026-09-18 07:44:57', 1, '2026-09-18 07:44:56'),
(235, 5, '5ce3af62daf964b54ed3faaafc1379da20673a2d66298fc24b9cb9c2f7147c6f', '2026-09-18 07:44:58', 1, '2026-09-18 07:44:57'),
(236, 5, '6759a305cd1f3d33786ea768bac77faae745de7be271372bd6f0a28696d59ab1', '2026-09-18 07:44:58', 1, '2026-09-18 07:44:58'),
(237, 5, '3b86f63c90ad590a8da5cc0f95aa83fd6104ca933950ecdb8158444f8d49bd2c', '2026-09-18 07:45:01', 1, '2026-09-18 07:44:58'),
(238, 5, 'a4f9a7d4aef5d26260b02c6d19e772e0227cbfbde913e9d4d33f755a44708149', '2026-09-18 07:45:02', 1, '2026-09-18 07:45:01'),
(239, 5, 'ba6dd48654e5c6b7971a1197f0be1f5989c026c1d23ae48c2f21a22b449633a9', '2026-09-18 07:45:03', 1, '2026-09-18 07:45:02'),
(240, 5, '9c00768d2189339cc23074ce623fc3539cd697d536b43270f19c1c5b399d111c', '2026-09-18 07:45:04', 1, '2026-09-18 07:45:03'),
(241, 5, '9646dc56ed5e268780295a41bd8c892872e5cf5f797750a70a581d15e094b48f', '2026-09-18 07:45:05', 1, '2026-09-18 07:45:04'),
(242, 5, '66514374afc7142a7fc95e406d5bfa9e7f1f92b63e916a11b6c8bc0d2796152d', '2026-09-18 07:45:06', 1, '2026-09-18 07:45:05'),
(243, 5, '49ba66dd9b395feddba93d78cb404e388d630747ae2122b1c190ed0af94d6354', '2026-09-18 07:46:18', 1, '2026-09-18 07:45:06'),
(244, 5, '9e68da9512583a6dcb864873f3faa0a9e865945b30c1d15c0d9b251dd30f190e', '2026-09-18 07:46:20', 1, '2026-09-18 07:46:18'),
(245, 5, '1fc019a77bd0656e2869d0af554594c22f03ff13f78ac0e41b872034c1ee3e8b', '2026-09-18 07:46:32', 1, '2026-09-18 07:46:20'),
(246, 5, '1a043a0c306aa4d155ad78a42bd33d8d25e26ddbb2b1ded7a6725a1dfeeac206', '2026-09-18 07:46:33', 1, '2026-09-18 07:46:32'),
(247, 5, '4c82f0846639960e30b75695828662f5da39103a0fdfe02b77897298b45ccd18', '2026-09-18 07:46:34', 1, '2026-09-18 07:46:33'),
(248, 5, '6264aa831197a3462775bcd564ab93862c30a32103148fc8ca35fc61dbab3b31', '2026-09-18 07:46:36', 1, '2026-09-18 07:46:34'),
(249, 5, '5debe3a901258ced9e0866c626779b4450a892019aa545b940cdc40e82ce6272', '2026-09-18 07:46:38', 1, '2026-09-18 07:46:36'),
(250, 5, 'da16be727ace78b85a978d5c8782e4cbdb87e4a0baf76fdfad6aea85d48201ef', '2026-09-18 07:46:39', 1, '2026-09-18 07:46:38'),
(251, 5, '3927b4b19366e5ca48fa71a5c36b3d1d0a829d2e4a6a6371981a9c37aeca2be0', '2026-09-18 07:46:40', 1, '2026-09-18 07:46:39'),
(252, 5, 'b623b72acb6fe08ed4f7a7b5ed5074433959f06aba8f74c6070284f20c7cffc9', '2026-09-18 07:46:42', 1, '2026-09-18 07:46:40'),
(253, 5, 'f2eafc4c906d059fe4945c1a8272a2db60ff413d85db36da3f8589644c7b0e35', '2026-09-18 07:46:43', 1, '2026-09-18 07:46:42'),
(254, 5, '8dc2b58e374ac7235b9a23ff95b06ffe08ee7bfadb6de3b2ec395d96277910b7', '2026-09-18 07:46:44', 1, '2026-09-18 07:46:43'),
(255, 5, '2d78a318db9e8d8d3ca483bfb036c527479c584a6632b8e507eb88ce1b0fc8c8', '2026-09-18 07:46:55', 1, '2026-09-18 07:46:44'),
(256, 5, 'ff2309eb8ec7451800a75e7d6f70a89af83ac3f137d23216a8c4508fa75c0c61', '2026-09-18 07:46:56', 1, '2026-09-18 07:46:55'),
(257, 5, 'a0b22b1a71b5a9e6e7d2c152417d7ddd0480a876275cde71fac747422eed2363', '2026-09-18 07:47:34', 1, '2026-09-18 07:46:56'),
(258, 5, '0f446f23ff08ca8340ccebe579d2382e1d84ebaaf0b9992d4859f8f8b7ef447f', '2026-09-18 07:48:01', 1, '2026-09-18 07:47:34'),
(259, 5, '7d555cd675565478fd464fd5f8b12f8844729e78dab8da80d64224e13a935a73', '2026-09-18 07:48:02', 1, '2026-09-18 07:48:01'),
(260, 5, '1591626f755c4a5c52672e01d4ade369d184102a2c0aa992e506700183231a6a', '2026-09-18 07:48:03', 1, '2026-09-18 07:48:02'),
(261, 5, '0df2a3b7a9d59ab7662aebd8c9ce49dbb85c4376dc921c836ca913cbef695a50', '2026-09-18 07:48:04', 1, '2026-09-18 07:48:03'),
(262, 5, '1ebc2a3b99aeff955220f4a263e9ddf1c2b4e1f65bed67fea4abe42513cc4b95', '2026-09-25 07:48:04', 0, '2026-09-18 07:48:04'),
(263, 5, '92ef939bef3b665eb055deb4e43d5ae1eada6c43d2a53770f2188f396438d9e2', '2026-09-18 09:02:56', 1, '2026-09-18 09:02:56'),
(264, 5, '81b1272da411dff68b2bc9795f772cc90ad5aa9e8cac3cf8063cd532b2d439d8', '2026-09-18 09:02:56', 1, '2026-09-18 09:02:56'),
(265, 5, 'f0745c23224b49faba9c4db5a387288cf5bb532e41cfed954ba69231658ff804', '2026-09-18 09:02:57', 1, '2026-09-18 09:02:56'),
(266, 5, '7e533cdd8260555c5444ff4c6e2fe16ad82607cedf65bee387e4dfb7eccca2bb', '2026-09-18 09:03:06', 1, '2026-09-18 09:02:57'),
(267, 5, 'd091671776a1225e24d9d03936d797a21821b21e3ac026b5fe489899caaa0c5d', '2026-09-18 09:03:07', 1, '2026-09-18 09:03:06'),
(268, 5, 'dfe6ab479f5e69cf7e180994ad301406ccd5fe13a2ea836085f9205e6fec29c0', '2026-09-18 09:03:09', 1, '2026-09-18 09:03:07'),
(269, 5, '6a679eaa1e707b067a665068ab3d97c99b21163deab96590643d309728c71ca9', '2026-09-18 09:03:11', 1, '2026-09-18 09:03:09'),
(270, 5, '085bc3d84626eedc5347dff3adb163071cf78c15fa167a01755e59fecd5668f3', '2026-09-18 09:03:13', 1, '2026-09-18 09:03:11'),
(271, 5, '83941b4c418c3e70cde3c54c63b4ab5b87acc09a3d02c018065dd56dd9bc2520', '2026-09-18 09:04:41', 1, '2026-09-18 09:03:13'),
(272, 5, 'cf7c4d3cc54b91174df40a80fa1f5646d577f07a3c4e193baeb628ffe5293785', '2026-09-18 09:04:43', 1, '2026-09-18 09:04:41'),
(273, 5, '1dfad7e3262ea72bb4c89cf7651d5c42644a00e4adcb88db481ce536d14995c6', '2026-09-18 09:04:47', 1, '2026-09-18 09:04:43'),
(274, 5, 'b96cef6c99cfe9d17f3a1de5ae82bd640e8b1e334948469430711136c66a2886', '2026-09-18 09:04:59', 1, '2026-09-18 09:04:47'),
(275, 5, '2470390596633dd24e11241cbd72d3a38553ae622d4b7b548f365c6305a8f8f6', '2026-09-18 09:05:01', 1, '2026-09-18 09:04:59'),
(276, 5, '2031a9e946b103045a69eee8921322dfc10114fb8eec2244fa92c613d771a446', '2026-09-18 09:05:03', 1, '2026-09-18 09:05:01'),
(277, 5, '52b486ce08b9301fd2eea7eabd3c172705538802e2881de3f58b8f7c9d8cd628', '2026-09-18 10:09:47', 1, '2026-09-18 09:05:03'),
(278, 5, 'd2aba33855b8d84c1549af747ad8d0af1cb360fa925c77b5e4e6079d5cc2c4e5', '2026-09-18 10:09:52', 1, '2026-09-18 10:09:47'),
(279, 5, 'dcb6c9bf00e0c2d6508f371c8c04b4a7c1ced885f239de882f386a93f757a3ea', '2026-09-18 10:10:15', 1, '2026-09-18 10:09:52'),
(280, 5, '6365f63d63fe8278acaa0d5dab9e128e4302e3da1c8b9531b8b06497414b9038', '2026-09-18 10:10:21', 1, '2026-09-18 10:10:15'),
(281, 5, '9cd1e147c5cdee846b841bb7390b04a1650fc11367529dbe724bb2b3a3671a78', '2026-09-18 10:10:33', 1, '2026-09-18 10:10:21'),
(282, 5, 'c7effa72c21f129b6418d3498d3160f39bfbd887e685b432d04ec82341abe6b1', '2026-09-18 10:10:34', 1, '2026-09-18 10:10:33'),
(283, 5, '85b2f0f9800b25451ff63e6eff9870d0fbfbd7624a629a47d40f66d1ff823808', '2026-09-18 10:10:47', 1, '2026-09-18 10:10:34'),
(284, 5, 'a064c58d1650cd6205b749023b860bee70604b29d49ef3513f3ebb7373478578', '2026-09-18 10:10:56', 1, '2026-09-18 10:10:47'),
(285, 5, 'a60dee380d308a6161a212854cd8679b4d8823c613c03960d6f1b5060e0e0284', '2026-09-18 10:11:01', 1, '2026-09-18 10:10:56'),
(286, 5, '721490daa2eaf43c1133a6b2ca8303288a5ccf0e76ff6545108c96928031e6fe', '2026-09-18 10:11:26', 1, '2026-09-18 10:11:01'),
(287, 5, '66580f967547dd4330868b07ab926be9710aec1f990bafda398a8b9c615a8c21', '2026-09-18 10:11:51', 1, '2026-09-18 10:11:26'),
(288, 5, '0f8a46b74f5986573ddb596eafa86825ce6fb7652afde8da97121559f79a8b86', '2026-09-18 10:11:55', 1, '2026-09-18 10:11:51'),
(289, 5, 'daec17bb45718b2ee1553264d8b4cb9a33df1c2b434eca4f87cb5c4f53a42a0b', '2026-09-18 10:12:03', 1, '2026-09-18 10:11:55'),
(290, 5, 'cc93ace2799aa76383989785269fce5104efb791838d7701c08727c19f0077c2', '2026-09-18 10:12:16', 1, '2026-09-18 10:12:03'),
(291, 5, '66afd7437f09e236b07a47b626952f5053caf81055c44a554c432e469a2dc947', '2026-09-18 10:12:30', 1, '2026-09-18 10:12:16'),
(292, 5, '37bdf3d7c38e81495a2c250e2853516c752c4e8e0ef4504a6da613fc790e3ce3', '2026-09-18 10:12:54', 1, '2026-09-18 10:12:30'),
(293, 5, '352ad95247566aeb53ef731df503d3c48b3edbca2227121bb1f9c6f1cb9903aa', '2026-09-18 10:13:10', 1, '2026-09-18 10:12:54'),
(294, 5, '8c0ecc66fcaa649ffda4cceba36f6ec880b868a6cd684c23db084ab46964a7d5', '2026-09-18 10:13:30', 1, '2026-09-18 10:13:10'),
(295, 5, 'a4a39e1631bd334bc431529062f704bda8d4b0459f8b4e9169f2bad48c84c8fb', '2026-09-18 10:14:01', 1, '2026-09-18 10:13:30'),
(296, 5, '70db8962542f3f80343a44f0d262f8da20f2e71418e2263db922bdf0a5bcd314', '2026-09-18 10:14:04', 1, '2026-09-18 10:14:01'),
(297, 5, 'ccb5c9c64823811cb933b7a03e439f4af2d4091b560ac0edfff0f04a407807ee', '2026-09-18 10:14:46', 1, '2026-09-18 10:14:04'),
(298, 5, 'f7cf00d033b618390dd1ea450057be93adf865cb0e939cda8052f54a050dc23c', '2026-09-18 10:15:47', 1, '2026-09-18 10:14:46'),
(299, 5, '92c8f3adb5f399c35def64e33c293ed52fc0ba5c978b8becae2232bb82bd5f04', '2026-09-18 10:19:45', 1, '2026-09-18 10:15:47'),
(300, 6, '724904bc9783136a66bc0bfc820123d40b36c2fc1f99fa3687d8b3d51509a9ca', '2026-09-23 11:25:03', 1, '2026-09-23 11:25:03'),
(301, 6, 'c6f755dcfe41371da9955e15ba85f1d33b65ce768d3c8e90635f5e9eb7c84351', '2026-09-23 11:25:17', 1, '2026-09-23 11:25:03'),
(302, 6, '3f00d0bda3a178a7224a3195b225bb0f4ebde26e16a08809245ce884e0396d03', '2026-09-23 11:25:26', 1, '2026-09-23 11:25:17'),
(303, 6, '1c26b53de06afcbd0499fa8e26fc174a73c44a7b83dad02c926862b7c686eaf2', '2026-09-23 11:25:55', 1, '2026-09-23 11:25:26'),
(304, 6, 'e498a56e014bbd9ae100d0091b59d9d4371e336babf04e96ef30162db09a7bee', '2026-09-23 11:25:55', 1, '2026-09-23 11:25:55'),
(305, 6, '1dfc19cbe3da276fed18d14b01285880ec9fd2daf76b4f1f234ffe20a94af128', '2026-09-23 11:25:58', 1, '2026-09-23 11:25:55'),
(306, 6, '95277d34b8e21362f4d9c9300c3dfd2a9850766e93d8bcfdfc073ec24a661cc6', '2026-09-23 11:26:03', 1, '2026-09-23 11:25:58'),
(307, 6, '906402cca97c3a8138053c03e7fb300cae35e24c92ca0436062830f704e66858', '2026-09-23 11:26:13', 1, '2026-09-23 11:26:03'),
(308, 6, '229aa735b9bf6888e548b15e709d8a6784fbb9a29e46f73d955dcb8c0c946baf', '2026-09-23 11:26:13', 1, '2026-09-23 11:26:13'),
(309, 6, '94cad5d9a72425ed52e078643bf3d4a1d00fb81c92063e0bd3436938c6b21b54', '2026-09-23 11:26:31', 1, '2026-09-23 11:26:13'),
(310, 6, '6b6d630ce75cce7a142547a7f8cfeeac217d1f0e1590688f4caf11384ce47d6f', '2026-09-23 11:26:33', 1, '2026-09-23 11:26:32'),
(311, 6, 'af962f13b99f7914d4e26a5caa3b417a0bcf1805fa760858b3e776fd9949cca9', '2026-09-23 11:26:34', 1, '2026-09-23 11:26:33'),
(312, 6, 'd8e3478ca402dfe682d4913294fac1ea9abfe772e1a342d1ac9dc9e8e9d0cdf1', '2026-09-23 11:26:44', 1, '2026-09-23 11:26:34'),
(313, 6, 'f78309eba98222651a30c5369def68a0652b03895e774d86df9f8f2bda62cb62', '2026-09-23 11:26:57', 1, '2026-09-23 11:26:44'),
(314, 6, '4542dd66d8b0a659d45a672e38481f0f62aeb91bf397cc00014cd81dc3a1e9b5', '2026-09-23 11:27:09', 1, '2026-09-23 11:26:57'),
(315, 6, 'bc5700c79913cc556083fe45a8df7b401c99992d1c9dec4c0e16e14ee395a923', '2026-09-23 11:27:26', 1, '2026-09-23 11:27:09'),
(316, 6, '3cce883969f91dd0392e99686379fc9e2eafbb7333a94e8d8a82edbeba8b66c4', '2026-09-23 11:27:38', 1, '2026-09-23 11:27:26'),
(317, 6, '7820ce5916822a329d55033347e568c22c9649cd6436ecf58f0dd274249c1e2b', '2026-09-23 11:27:40', 1, '2026-09-23 11:27:38'),
(318, 6, 'ef8a659c2de9bf8f6181cfe1c0c47437aa25625e7d79df90053c2e01b5d4bddb', '2026-09-23 12:01:04', 1, '2026-09-23 11:27:40'),
(319, 6, '712efe59124f600ccff826714153e4bd3d1d4aeeb0aea449af0b0e25af48dc50', '2026-09-23 12:01:04', 1, '2026-09-23 12:01:04'),
(320, 6, 'c57f3bdbf90f2fc55fbfcb2aeff089fa7fd206833db055ee898ea41a70014ad4', '2026-09-23 12:01:14', 1, '2026-09-23 12:01:04'),
(321, 6, '439ccf1d1c94fadc2e99f4e8d6657dde201d68e10abf8b367e76cee72cb6621d', '2026-09-23 12:01:25', 1, '2026-09-23 12:01:14'),
(322, 6, '2f410739036da0ccda16a418ee5a16c9a058c4632e787f369c9b78fa10cf4b29', '2026-09-23 12:01:36', 1, '2026-09-23 12:01:25'),
(323, 6, '24a0c0965de65ad5459293252248bca2156107019e9ea413391e0c809fc23161', '2026-09-23 12:02:58', 1, '2026-09-23 12:01:36'),
(324, 6, '3c2e05db603a9f63748d444d297bb8fc83353190334084caf5a3b78cc850e3a4', '2026-09-23 12:03:01', 1, '2026-09-23 12:02:58'),
(325, 6, 'aa101b01f5bea840d86b59effc3a37e2446ccf7e761307e8c1d0a5fa87672122', '2026-09-23 12:04:41', 1, '2026-09-23 12:03:01'),
(326, 6, '8929ce19fe5e82066c900cc37cc63bb3ebb601a091fbd247c63937a8f3708839', '2026-09-23 12:04:43', 1, '2026-09-23 12:04:41'),
(327, 6, '6a8c5261510cc5c67d7bf2bb4ad7ee864cab9ef74ef293479c51062e2f145fda', '2026-09-23 12:04:45', 1, '2026-09-23 12:04:43'),
(328, 6, '5be9366895375f0bb50f610855573c7e39bb4c3462b1ab39b9473647fbdcf6d3', '2026-09-23 12:04:48', 1, '2026-09-23 12:04:45'),
(329, 6, '7e35027a5a33d9be25cd4fa07078f4430441bf9fe6d47e7dcf39cc9b839cd308', '2026-09-23 12:04:51', 1, '2026-09-23 12:04:48'),
(330, 6, 'bba31673d1ea5a26c2cc2d4b77b40b6cce2fe53264230374c0fa1c12160e1434', '2026-09-23 12:04:52', 1, '2026-09-23 12:04:51'),
(331, 6, '3e0f3496dca2cdab2e71806b944afe578dfddf4000ba992d330e22c16e32e439', '2026-09-23 12:08:53', 1, '2026-09-23 12:04:52'),
(332, 6, '236224c7f147614ec1b8768633178bb9617feeb880d8509f15db029d47f67828', '2026-09-23 12:09:08', 1, '2026-09-23 12:08:53'),
(333, 6, 'a0334ead378bae5c0f444858930665ef7a93a8a52e72982b94bf04607a150ba8', '2026-09-23 12:09:10', 1, '2026-09-23 12:09:08'),
(334, 6, '16e4cbaeef249c2a243d9442ee5e5fba0b98dc26256abf00916b3492a2dc9337', '2026-09-23 12:09:11', 1, '2026-09-23 12:09:10'),
(335, 6, '48263cd8b1c5a2b107aec0014344c4157d6786284908b1ae8264e23551fa7d26', '2026-09-23 12:12:18', 1, '2026-09-23 12:09:11'),
(336, 6, 'c2acd5b546a2460b04b22250e4eba40536c5fac5e684a4d42304b8669621e07a', '2026-09-23 12:12:20', 1, '2026-09-23 12:12:18'),
(337, 6, '7246087de85fed853767f5ae388aa7b7b95fcda7dd83384fe0116c58669df9f5', '2026-09-23 12:12:21', 1, '2026-09-23 12:12:20'),
(338, 6, 'c73ebfc5f75ff02a9d1cd0daf8ac9db8f050be4f601b0263ee1cfaedf889639a', '2026-09-23 12:12:23', 1, '2026-09-23 12:12:21'),
(339, 6, '53e426032c19a3837e207a6d2f91488de47018dab2eb77227405d6a8aabbae95', '2026-09-23 12:12:27', 1, '2026-09-23 12:12:23'),
(340, 6, 'c0ded3787efd526b42772b42ec4d01fb3e1c69fb1b66b35c6afdb2ba02b0b4a6', '2026-09-23 12:12:28', 1, '2026-09-23 12:12:27'),
(341, 6, '2ad859f82dfc718b0cddc07c584f384feb504c8927609cb68c054c4410cd2474', '2026-09-23 12:12:30', 1, '2026-09-23 12:12:28'),
(342, 6, '7a6eec4f8edbc88f007ea4165f9bc181aff76d5435d3359f917513285eacad26', '2026-09-23 12:12:31', 1, '2026-09-23 12:12:30'),
(343, 6, '111d0f60b797a160db71c0ee9dfec6d3a145b380c8998fe85ef9c080948c5b97', '2026-09-23 12:25:48', 1, '2026-09-23 12:12:31'),
(344, 6, '848842477636914b5d9156f3dd06764abc0a655556affadab0893d4ee4e167b1', '2026-09-23 12:27:11', 1, '2026-09-23 12:25:48'),
(345, 6, '371a563167cac0c0a743fa0206cb051b97ffccd1d4eb5cca37e12b1446bef79f', '2026-09-23 12:27:16', 1, '2026-09-23 12:27:11'),
(346, 6, 'dc656255f7782fb542bb2d26bb14040bfd04ba88802699a5fa616aaca8907727', '2026-09-23 12:27:16', 1, '2026-09-23 12:27:16'),
(347, 6, 'd25681cf735dfc649b5a4f4afce76b5b0155c7cc7c3f320f9a7d8ef6149d155e', '2026-09-23 12:27:18', 1, '2026-09-23 12:27:16'),
(348, 6, 'cd08edea6e07f217062e6082d1d9529d456085261de972e0a6febd766394a784', '2026-09-23 12:27:19', 1, '2026-09-23 12:27:18'),
(349, 6, '9b55858eef9fa3f813acfcb8d379c2d3c37faee0c2d74a12db4c99027924394f', '2026-09-23 12:27:21', 1, '2026-09-23 12:27:19'),
(350, 6, '9a54b0633a7efcbb6e449f158b4d90caa1bd3ebdda274d213b293504b1b16b22', '2026-09-23 12:27:23', 1, '2026-09-23 12:27:21'),
(351, 6, 'eaff860def971b3b373280e9b6b90a8c834ab6e678f43637e12759e38f649950', '2026-09-23 12:27:24', 1, '2026-09-23 12:27:23'),
(352, 6, 'd1aee3fa26ce7d79362e052b2b055994e323dac4568a8fd7b895fbadf27321be', '2026-09-23 12:27:30', 1, '2026-09-23 12:27:24'),
(353, 6, '9f1d717bbbe2b267f8dbf34f7ef58c759be59780a8fe83c39d8721d23f3e5e26', '2026-09-23 13:31:48', 1, '2026-09-23 12:27:30'),
(354, 6, '6b173efa2c736edb7e19fd98fda50e652b861ec207f14dd737866b57e8903158', '2026-09-23 13:31:52', 1, '2026-09-23 13:31:48'),
(355, 6, '268a25afe11fb32232f6de4570fc0977dfad297937b6a9cbee5b3d8402e839e5', '2026-09-23 13:54:17', 1, '2026-09-23 13:54:17'),
(356, 6, '71619d0e20fae18578cc12bb3a34e26f16bb2d5cefe31cb089ec15c27938e30b', '2026-09-23 13:54:17', 1, '2026-09-23 13:54:17'),
(357, 6, '2df5e177efa927d9f53212064fbb78e85e4697de85dab5d9481b9a9519a6c82c', '2026-09-23 13:54:24', 1, '2026-09-23 13:54:17'),
(358, 6, '04558819331ad351c195a58036e5dd2d8a7eca1d315f927191a70b7f2a7204c3', '2026-09-23 13:54:25', 1, '2026-09-23 13:54:24'),
(359, 6, '925267a45e4c6bf7eaf1685f68da16981fb66f2a90abb4ed757c264ef78919c5', '2026-09-23 13:54:29', 1, '2026-09-23 13:54:25'),
(360, 6, 'b59fa18a95ad3cddc54505e319edf2a06be1f678ca15bdb3ca133ecd06bd3c99', '2026-09-23 13:54:35', 1, '2026-09-23 13:54:29'),
(361, 6, '8f632ec7c51bee0ab90490fab3b7f0895f2e1089b6cb549c84bd400de45bee10', '2026-09-23 13:54:37', 1, '2026-09-23 13:54:35'),
(362, 6, 'e71991962ad510029d6bf75df4a1be2290bdfcb2a1bc05534ed4346af7366d27', '2026-09-23 13:54:40', 1, '2026-09-23 13:54:37'),
(363, 6, '51e3ca5568588bda7a195baac5a1f4911d770cdecb7a24cc7d03a6825a29ebf6', '2026-09-23 13:54:56', 1, '2026-09-23 13:54:40'),
(364, 6, '38cd07b765ab806b63f4592287370728275a3cb9bb30557a702754812ad943c4', '2026-09-23 13:55:05', 1, '2026-09-23 13:54:56'),
(365, 6, 'ae5cd6fc128244382bcd3c60f8e957a59da757360ff58028f3f969446ba95096', '2026-09-23 14:03:33', 1, '2026-09-23 13:55:05'),
(366, 6, '40e966db034d4a5ebd83f163644f5e9d8f578d2c7dbbc331c09128c7d4cd4ab5', '2026-09-23 14:03:35', 1, '2026-09-23 14:03:33'),
(367, 6, '954a35e4358c23a3de367d65d210e2cf63bae0f11840b0d8e75b98d15a237335', '2026-09-23 14:03:37', 1, '2026-09-23 14:03:35'),
(368, 6, 'b87dc4ebe05d970979fa8eb651db7dd8678f25c5cfb862f6416df132058aa7d5', '2026-09-23 14:03:39', 1, '2026-09-23 14:03:37'),
(369, 6, '0aedf17f65a050a01c28d59fe089ef8c6ffa725e2c6efdf39cef29251b0ddad2', '2026-09-23 14:03:40', 1, '2026-09-23 14:03:39'),
(370, 6, '3e23a9f8fffbbc1c5b3d121989601f72138deb4395584a00a7da8174005b996e', '2026-09-23 14:03:55', 1, '2026-09-23 14:03:40'),
(371, 6, '476bf0e8fa4bcf43ab80846657e5d61c2f387e4018071e8a62ececb4f19c712f', '2026-09-23 14:03:56', 1, '2026-09-23 14:03:55'),
(372, 6, 'b983e9cc3104794f9ec66985c6413cb20215d6de93f6bcbaab7cdfce9dbb3e1f', '2026-09-23 14:03:57', 1, '2026-09-23 14:03:56'),
(373, 6, '9455a102551c6bee5b9373f3bcb15a7014c664d09780aff091cb78564f863a4f', '2026-09-23 14:04:00', 1, '2026-09-23 14:03:57'),
(374, 6, 'e8567a9d9c0b384464de16c90775d2aabffda7241b9c6e5e1456160416e8fc6d', '2026-09-23 14:04:11', 1, '2026-09-23 14:04:00'),
(375, 6, '040ba1fb9aa3f63a53d8d4ba740f0034e47012b7e72f9d3027c5e33203a506c3', '2026-09-23 14:04:12', 1, '2026-09-23 14:04:11'),
(376, 6, '22f30a08e139df341b75e6863effeac94b6a1959f064195a72dd92ea01478b80', '2026-09-23 14:04:41', 1, '2026-09-23 14:04:12'),
(377, 6, '5b572a47ebcde7640db2429fce680f65cd122a24cc5c83d30658b181506114d9', '2026-09-23 14:23:12', 1, '2026-09-23 14:04:41'),
(378, 6, '8c3da9d5dd168241bfa25362af43212121a0aaad20b3ff4a34b407280bbac701', '2026-09-23 14:23:14', 1, '2026-09-23 14:23:12'),
(379, 7, 'ab245426f568d15815a4add4ad74712fa873a1a66f7967c9de384ab652176559', '2026-09-23 14:24:14', 1, '2026-09-23 14:24:14'),
(380, 7, '9ce9f290d2d2ad4381d2f4f70a4dc0c429779910d81ea0234a0c8b231b2cac75', '2026-09-23 14:24:20', 1, '2026-09-23 14:24:14'),
(381, 7, '983b96f3d731fa96bca0e014da6b8a4a848e685f55cccd7b0d211f989d64299c', '2026-09-23 14:24:50', 1, '2026-09-23 14:24:50'),
(382, 7, '2cf618cb069df6c45943d1d3d62d8075952fb303e222a30c54ab8fccd35604b2', '2026-09-23 14:25:22', 1, '2026-09-23 14:24:50'),
(383, 7, '9079b01423bd8f7f8ec1644bdc2bff447b2e007abed0e2f610d44e146f40b082', '2026-09-23 14:25:26', 1, '2026-09-23 14:25:26'),
(384, 7, '6a2b215e504fc6ce8224458cd63ebee781398ffadba1dc4aff571017c7a2194a', '2026-09-23 14:40:28', 1, '2026-09-23 14:25:26'),
(385, 7, '862a144c290671d5c69dce18d314194b8b2c0feda42c60c49819c4cd2945804e', '2026-09-23 14:40:34', 1, '2026-09-23 14:40:28'),
(386, 7, 'd5cb78c52d43964d1b89b687039b18f02e5ffccf876f7acae07ec9a6fe9532fc', '2026-09-23 14:40:34', 1, '2026-09-23 14:40:34'),
(387, 7, 'e08176afb0c2de7cc3dfa84e67dec9c1d7f868b8e2af3c6eafb6533738144c31', '2026-09-23 14:40:41', 1, '2026-09-23 14:40:34'),
(388, 7, '9e06e9d0a1287d568da791ad64e9ca5d318e9c35c4b1230ca447ee56d1d55985', '2026-09-23 14:40:41', 1, '2026-09-23 14:40:41'),
(389, 7, '1a02f89e6abb095effdfcc6e4f8795429564c5500778debd2093c681bdb9cc79', '2026-09-23 14:40:47', 1, '2026-09-23 14:40:41'),
(390, 7, '5eb505986c5b5710c10ca380d0d0d39162174e2bee1dc731e6f06644fb418601', '2026-09-23 14:40:49', 1, '2026-09-23 14:40:47'),
(391, 7, 'bd7c0f37764b6e9cccf6326e45d79bbc5b5bea6543c77a0fedeb2a941f03558c', '2026-09-23 14:40:50', 1, '2026-09-23 14:40:49'),
(392, 7, 'd69e8e9b0715179e19dde32335d96a30a776f24af5088828035b6393697408d4', '2026-09-23 14:40:54', 1, '2026-09-23 14:40:50'),
(393, 7, '4b3bbe70b0eff1ffc5cabe20c37976587a86948e23b5dae931cb42bf393d4b82', '2026-09-23 14:40:55', 1, '2026-09-23 14:40:54'),
(394, 7, '7b947d38d0ff649dc5e3ab474856cab2d85475a6ccc7ef8643328e71d4f92916', '2026-09-23 14:41:04', 1, '2026-09-23 14:40:55'),
(395, 7, '819f884abfdbae4617e91a01b8e074bf52bad4ab73ac25cb1a2739c96b48cc1c', '2026-09-23 14:41:07', 1, '2026-09-23 14:41:04'),
(396, 7, '296810b48d30111436896e2485fe5f0f54d2caa919a59ef55b168dee68e110e0', '2026-09-23 14:41:10', 1, '2026-09-23 14:41:07'),
(397, 7, '7a26e0919c70c9f3bb0a3c4a84a61adbf2228a56d5e7a764415f720f4f1fca77', '2026-09-23 14:41:10', 1, '2026-09-23 14:41:10'),
(398, 7, 'c9d924d5650faaf578e75bc7b0532625befde150a523bfd427c2a658f739a762', '2026-09-23 14:41:14', 1, '2026-09-23 14:41:10'),
(399, 7, '4e8296ab673c46562e787825d99b4606e979d0fe3ac7db63c1a67b8313cd6341', '2026-09-23 14:41:21', 1, '2026-09-23 14:41:14'),
(400, 7, '56e5c1e89842cdde37d4fda0129890ad353703aaaac7e266ff7bd94864dd9324', '2026-09-23 14:41:27', 1, '2026-09-23 14:41:21'),
(401, 7, '385cfbcb66bc6019e0f3db7069ed66ec05c1454a57054aafdc48ce9fcd3773e0', '2026-09-23 14:41:28', 1, '2026-09-23 14:41:27'),
(402, 7, '076529a0c4ebd9aebc1125fd4812a80617ffd6854107c419a9090bf37926b8cf', '2026-09-23 14:43:08', 1, '2026-09-23 14:41:28'),
(403, 7, '85de88596a1792063d12ee24560971ec02af3b66c5791c5387e676bbd1d6b2ee', '2026-09-23 14:43:08', 1, '2026-09-23 14:43:08'),
(404, 7, '4048f3abf6787ee89f78e5c9c495f1b77db36afd1d2f26c02472dd273a7deb89', '2026-09-23 14:43:11', 1, '2026-09-23 14:43:08'),
(405, 7, 'a5b6e9ab54b7f8c406f6901e78d018e5e11ae0b63b9b5a690198fbc00bfc7ecb', '2026-09-23 14:43:14', 1, '2026-09-23 14:43:13'),
(406, 7, 'b5c00200c991e650af870c5bf33e04e766242d0314249d42b170015619337e53', '2026-09-23 14:43:17', 1, '2026-09-23 14:43:14'),
(407, 7, 'be29130d1dff62bbc1ab5bf9adc69b4b86c7f5de5e740a5499484dd929bdbd38', '2026-09-23 14:43:19', 1, '2026-09-23 14:43:19'),
(408, 7, 'd7c1e20cefd0b76c6c3bc2377fdd29d52c175851dc74c47f8d260d49663eb9c7', '2026-09-23 14:43:22', 1, '2026-09-23 14:43:19'),
(409, 7, '353d31119b0148754a3603c8d9088d7da71781a27a6bd9adf51d213241239a7d', '2026-09-24 11:04:27', 1, '2026-09-24 11:04:26'),
(410, 7, '087bb4c5d4e50a101889f88601d3e6cc0ebb2ff0ca62950a642eadb3228571de', '2026-09-24 11:04:32', 1, '2026-09-24 11:04:27'),
(411, 7, 'd1775580e0a92bc5895241b26fe1b42602c10475ccd39d676fc5bdb640411826', '2026-09-24 11:04:32', 1, '2026-09-24 11:04:32'),
(412, 7, 'ab4413906875aa610d7099d1786c9bb09e9157a582fb24c6ad0cc834e9b84a6c', '2026-09-24 11:04:35', 1, '2026-09-24 11:04:32'),
(413, 7, '01b65847ef16443cbcd28f54184af5444e9619e7357cd6ff9022004d91ac1856', '2026-09-24 11:04:53', 1, '2026-09-24 11:04:35'),
(414, 7, '7d8e91b86544bf817ab672a70ad53095fc33aa541b80905f282879cf88582107', '2026-09-24 11:04:57', 1, '2026-09-24 11:04:53'),
(415, 7, 'b5ddea1026b1fede09d25549763d6e63a8b025ee61bfb914a2d85f5ec5f9afb1', '2026-09-24 11:04:57', 1, '2026-09-24 11:04:57'),
(416, 7, 'd9abca4e211276b791e56a7276352290ec9194dbff8e88a2d59e5e82177120cf', '2026-09-24 11:05:00', 1, '2026-09-24 11:04:57'),
(417, 7, '5663a15bcaad99dd3c0e5c3e16f97281fe86b2e9e13a2b9f993c0fae8a8c814a', '2026-09-24 11:05:21', 1, '2026-09-24 11:05:00'),
(418, 7, 'ba88da6e0a029533c522f7821a63834d7e2ea23ae9efbb31ed97c045af63b0a3', '2026-09-24 11:05:24', 1, '2026-09-24 11:05:22'),
(419, 7, 'bd1b79bc554bdb73ecf35940edc13310b12dcd6474683c76eabb8cf0d8fd2133', '2026-09-24 11:16:58', 1, '2026-09-24 11:05:24'),
(420, 7, 'f6342ef9702e33ab6f07fd99c5cd4f1485793e0e4da71e5e7ec21b3d8d4bf77b', '2026-09-24 11:37:21', 1, '2026-09-24 11:16:58'),
(421, 7, '84f28a37ff23a5ec611c336064473a9f661014c21ac274364ced4a50a528785e', '2026-09-24 11:37:21', 1, '2026-09-24 11:37:21'),
(422, 7, '275b27237db8278a5da3e72ec2c3f7d632c7ab7432427ef8c41bb1e05937f758', '2026-09-24 11:41:54', 1, '2026-09-24 11:37:21'),
(423, 7, 'fe8cf1e9d9716c4dac2fb464703159a759bd35f6e8b306c5b305f3d1eb4473d7', '2026-09-24 11:42:04', 1, '2026-09-24 11:41:54'),
(424, 7, '5ea743f92ab3cfeee6dc406129038fc8d2f46e04b86fef4322005824d162bdd6', '2026-09-24 11:42:08', 1, '2026-09-24 11:42:07'),
(425, 7, '19977dd5edb7e6b9557418d96e3ae73765873320ef72a0e283cc7248b1af083e', '2026-09-24 11:48:23', 1, '2026-09-24 11:42:08'),
(426, 7, '568f4f093423e7e237bd365f1652eca5817817573fa02d143b7e6892c8a38b50', '2026-09-24 11:48:23', 1, '2026-09-24 11:48:23'),
(427, 7, '4027fcd99a4aecd1f6c8c9654275f314f04356eeb211b7481ff96cbfab0c200b', '2026-09-24 11:48:30', 1, '2026-09-24 11:48:23'),
(428, 7, '30c6658fd86c1a2baf9b4b8377970cf1336e80e0d910ebfc443cb2649bdc4efe', '2026-09-24 11:53:20', 1, '2026-09-24 11:48:30'),
(429, 7, '8088d1be0ee3b0545e50e0ed09001958a40aef82e16a69b376929ed0fa2337df', '2026-09-24 11:54:27', 1, '2026-09-24 11:53:20'),
(430, 7, '759e3bf993d862e027e8b567ddebae71e6b029f7dcd0767cdcf510dce76abc85', '2026-09-24 11:54:34', 1, '2026-09-24 11:54:33'),
(431, 7, '9623c729b60c3e3f2b2f5277519e943bf472b955c3a9b863f4678b6d4b0a1827', '2026-09-24 11:55:00', 1, '2026-09-24 11:54:34'),
(432, 7, '082b351aeb1569a2d1678f0b5ccaa858561ba61d5319af6588a3e67049f6009e', '2026-09-24 11:55:05', 1, '2026-09-24 11:55:00'),
(433, 7, '462f2ae5388f666eee45ffcc311a53fc82731066051459b8ee6123227808ba7b', '2026-09-24 11:56:21', 1, '2026-09-24 11:55:05'),
(434, 7, 'fbe72a3a531def1801c323f2f1ee9e3cea59488d05642929e733eea1a975141a', '2026-09-24 11:56:21', 1, '2026-09-24 11:56:21'),
(435, 7, 'da13e30d1a2f8a62cdc2287a533b658850175229f9a6928abd4d9cada207464c', '2026-09-24 11:56:23', 1, '2026-09-24 11:56:21'),
(436, 7, 'c273abd138633da1ab50a5ec723efe148ac3be9d13172698cdce41acdfd3755d', '2026-09-24 11:56:25', 1, '2026-09-24 11:56:23'),
(437, 7, 'ac58ebfe723536c8e63737b523e50338d9f8e6edb01a7c22bdb559ba92e0c3fa', '2026-09-24 11:56:26', 1, '2026-09-24 11:56:25'),
(438, 7, '35475bd53537b9e3f269e8f7b9592652eea2435f72dbaae33f98e0df30d93393', '2026-09-24 11:56:27', 1, '2026-09-24 11:56:26'),
(439, 7, '3ebd8400bcdeeb6c1eb9ed39e973ea69ade314c872266222dda464f05e920b27', '2026-09-24 11:57:18', 1, '2026-09-24 11:56:28'),
(440, 7, 'b5159445be75fa9cd4fe934106576d937b8eb92eb69c05c942d2ad1d71b7fb3e', '2026-09-24 11:58:25', 1, '2026-09-24 11:57:18'),
(441, 7, '9953260a16d7a4056feda7189dbff5c481ac5f16eb3034ddb95228803ce297d5', '2026-09-24 11:58:27', 1, '2026-09-24 11:58:25'),
(442, 7, '0cb1971c07ebc703244e3ac931a689a64ee9cf1604c794f7e9e8d12e659bb8f8', '2026-09-24 11:58:27', 1, '2026-09-24 11:58:27'),
(443, 7, 'b211ef4c0551663f4d2b8f4cb63f8e1ffa0dc339b7fdbb2636d622444148631d', '2026-09-24 11:58:28', 1, '2026-09-24 11:58:27'),
(444, 7, 'a2891cfee176a28eebdac7619fe5c5bfbd96426d76e50854cd3ce2b1bf758770', '2026-09-24 11:58:37', 1, '2026-09-24 11:58:28'),
(445, 7, '53cc842011bb080889c8f258cfa54d94aa5b26903f0389b6b7a6881d5c194452', '2026-09-24 11:58:56', 1, '2026-09-24 11:58:37'),
(446, 7, '93dba0b9241b229a1e953e93157fccc2e379e28b7ef76ef0f2106aa091a23ccd', '2026-09-24 12:01:49', 1, '2026-09-24 11:58:56'),
(447, 7, '20a06a1cdc54b53a563b912847fa373929329b10ebb10113beaab208865e50a3', '2026-09-24 12:01:52', 1, '2026-09-24 12:01:49'),
(448, 7, '76d4242c24b73c2b6442ffd06d034234c9fa76aeace57ddff796dc96cbb9b92b', '2026-09-24 12:01:53', 1, '2026-09-24 12:01:52'),
(449, 7, '69811c04d6e087706bf8d69813a8988b5856c19a36541ac0edb8712439d2d8ce', '2026-09-24 12:01:53', 1, '2026-09-24 12:01:53'),
(450, 7, '18bd49af753d1158cd6b678be5a9c274d186a92c4b0e815b6abd3abb9d5df8a7', '2026-09-24 12:01:55', 1, '2026-09-24 12:01:53'),
(451, 7, 'cadbec733c519d69829fed99c7ac8f2b0ffd857c3ab9b61fe08066aa14a891ec', '2026-09-24 12:01:57', 1, '2026-09-24 12:01:55'),
(452, 7, 'd429bc5485eb4f8533d3a64542fe509c8658bd50049af01e08d54f301462f954', '2026-09-24 12:09:21', 1, '2026-09-24 12:01:57'),
(453, 7, 'c015a226c27258914267cda8140fd99d8c038d067510e5aac8bde36a45ecc93e', '2026-09-24 12:09:28', 1, '2026-09-24 12:09:21'),
(454, 7, '2900ab9214fdd7b895c0bad97438163472ae54b1ab7c09fca514ff2e6a765d79', '2026-09-24 12:09:31', 1, '2026-09-24 12:09:28'),
(455, 7, '9340aabdc9a2deccddd9c5dcfbf48eb9fbbf049fd0bdf55d909d2c4e8913206f', '2026-09-24 12:09:32', 1, '2026-09-24 12:09:31'),
(456, 7, '3b2dda208f05a2c5f771574c00a99ce27bc25f3063ee06951d03d31a6e550a38', '2026-09-24 12:09:32', 1, '2026-09-24 12:09:32'),
(457, 7, 'b5a6d64dfa0a7b456d294fea6a7925c3cd1d6828d14fa42501757c79ae053ecb', '2026-09-24 12:09:34', 1, '2026-09-24 12:09:32'),
(458, 7, '18fd684ef4a2a1755379a2ce4c35326690c9b0d06bb7135e85e671427be51f58', '2026-09-24 12:09:36', 1, '2026-09-24 12:09:34'),
(459, 7, '2adcaa0652a6543fed0b2834e3922d70856b59a25d27fe9221e20756f4fc7b85', '2026-09-24 12:09:44', 1, '2026-09-24 12:09:36');
INSERT INTO `refresh_tokens` (`id`, `utilisateur_id`, `token_hash`, `expire_le`, `revoque`, `cree_le`) VALUES
(460, 7, '23100bf7147e5db9458a57cba03c55cba097bb15ff0bfa00b437cb8b2e6bc96f', '2026-09-24 12:09:46', 1, '2026-09-24 12:09:44'),
(461, 7, '6aa5ff6c7eb2f822dd89e5be89082dd75f5eb99460eba50e7b7cba1b3918cc89', '2026-09-24 12:09:48', 1, '2026-09-24 12:09:46'),
(462, 7, 'eb07566985cc4c4bb251c680c63953a9868a9969fe554dcf9e14921b6034afea', '2026-09-24 12:09:55', 1, '2026-09-24 12:09:48'),
(463, 7, '487e0fd1c71a020836b86f45bfa9abe319ebf1b8ed540c2c800c8332875fc921', '2026-09-24 12:09:57', 1, '2026-09-24 12:09:55'),
(464, 7, '8a8cbaeadb4eadcf75b5ae2b249e16ea014219630f96f78acc322786a55073b6', '2026-09-24 12:10:15', 1, '2026-09-24 12:09:57'),
(465, 7, '4f2b17bc664f3e1b8ab0e53c3f71452f759821188fdfed6ff231ee0421a302ba', '2026-09-24 12:10:23', 1, '2026-09-24 12:10:15'),
(466, 7, 'fc5c10f7de96bfe2de47ba1f04e4b777ef6ea9d584026db5cc94a26be9ee7afd', '2026-09-24 12:10:23', 1, '2026-09-24 12:10:23'),
(467, 7, '491680a1a109c976a38eadae34e5ed37286f82c49517997b4303a0cdb69037db', '2026-09-24 12:10:25', 1, '2026-09-24 12:10:23'),
(468, 7, 'f9ec2cd7ea8b9e76a0b6d01219ca5fad6e5d89e0fe4306a2d02a1eee8ec56566', '2026-09-24 12:10:28', 1, '2026-09-24 12:10:25'),
(469, 7, 'd7799525c2c50a09bd932e148e1cb335d47dd2d1ce3b4a61c851e8bfc341b8f9', '2026-09-24 12:10:42', 1, '2026-09-24 12:10:28'),
(470, 7, 'a21ccf384a16850b4c2158bd4f4789bc895f566901d6080a967f107e1e8da786', '2026-09-24 12:11:07', 1, '2026-09-24 12:10:42'),
(471, 7, 'ca2797790148bccc7ae8201c4dc310c8ed8e5cf17756a2a7b2cbc467a3c3f954', '2026-09-24 12:11:09', 1, '2026-09-24 12:11:07'),
(472, 7, 'b53e9ddf35c748e072d9298bcf800fd037e669ae26b98713506689e5f43db000', '2026-09-24 12:11:14', 1, '2026-09-24 12:11:09'),
(473, 7, '189cadfe5b5c6524cc166967a877775342bbd08f091469f6fa2a4abf422f9eb3', '2026-09-24 12:11:16', 1, '2026-09-24 12:11:14'),
(474, 7, 'f6dff741ba4caaac216ff0bc5ceaa848c16a96c38805527f94c91f2ac7277753', '2026-09-24 12:11:54', 1, '2026-09-24 12:11:16'),
(475, 7, 'cd48d764d1a20a5ec4a31da02e14f4f752d35d3d69d8a418e24297e26801d5c0', '2026-09-24 12:11:59', 1, '2026-09-24 12:11:54'),
(476, 7, 'c964bd2e1abc2e0da1ea64196a8c9058ebc98889bd5bc550ca4f5f600fdfadcd', '2026-09-24 12:12:06', 1, '2026-09-24 12:11:59'),
(477, 7, '9d3bc748528400f7e745130a41b8f7b4a377b1c96d0567300430b8e627561ef6', '2026-09-24 12:21:45', 1, '2026-09-24 12:12:06'),
(478, 7, '40df48046868fa4473755f34308074738f712f658531c0da6a1b8f412359258b', '2026-09-24 12:21:52', 1, '2026-09-24 12:21:45'),
(479, 7, 'bbae4a1cf810823e50f77548b0595dfd1ba9c516c1057a5a3affa117a055871f', '2026-09-24 12:22:01', 1, '2026-09-24 12:21:52'),
(480, 7, '6e67f8db2ef14259ebd088d76c1f504959cb1616a4b1dc1950a6d523ba85c2a8', '2026-09-24 12:22:03', 1, '2026-09-24 12:22:01'),
(481, 7, '1a756678078ecce11732ac76ea2174155c7c3940e84083a7455b363dda9f70eb', '2026-09-24 12:22:14', 1, '2026-09-24 12:22:03'),
(482, 7, '4804345101715b4976565a79428ac8adcfbe4710ee7c8d83142ac62a5a5f5a04', '2026-09-24 12:22:14', 1, '2026-09-24 12:22:14'),
(483, 7, 'aa58b862e2b779dbf9ebe50ba3c7fb7a812bd2e60c055d02ccba5a13f2b511dd', '2026-09-24 12:22:22', 1, '2026-09-24 12:22:14'),
(484, 7, '5a258092649c09cb4c72ba02ea5764fdf87e8e267026e790927940dbfb025f35', '2026-09-24 12:22:29', 1, '2026-09-24 12:22:22'),
(485, 7, '1133251170d79eea0ac114abf8462c6209a5ea7cb8e1a5ce3d3d29c0f1e1bfae', '2026-09-24 12:24:18', 1, '2026-09-24 12:22:29'),
(486, 7, '1e10eb73b2ac69f63693648de7c1d969df88358d87417f3e87fb6e93ca163dc5', '2026-09-24 12:24:20', 1, '2026-09-24 12:24:18'),
(487, 7, 'f19d807862c95a5e2c684da46ac302bce4a15f60fe68aa4f5134ca61edc31303', '2026-09-24 12:24:22', 1, '2026-09-24 12:24:20'),
(488, 7, 'd6f80ac0340d20b8e65b391d66459b6bde29954060bc2bf4306377ab8d7d7b0e', '2026-09-24 12:24:38', 1, '2026-09-24 12:24:22'),
(489, 7, '0b8402b2ffa7ee35854aed4095ca0c45045eab55ad30870b3fffb5931167756b', '2026-09-24 12:29:04', 1, '2026-09-24 12:24:38'),
(490, 7, '47d3a44481b658b3ab921f2d6bdb2158f33810ac5ef30cee05c9d6d02962a071', '2026-09-24 12:29:07', 1, '2026-09-24 12:29:04'),
(491, 7, '6eb8a12983975faf9259479619f389656b0f39d6adc47a071d77738306d54238', '2026-09-24 12:29:09', 1, '2026-09-24 12:29:07'),
(492, 7, 'af05a6d76200833b4a61cdab64ea316258faea738b418bab45aad045e7260a63', '2026-09-24 12:29:11', 1, '2026-09-24 12:29:09'),
(493, 7, '0c8d82c65554cc98ce5bcd15f8c64628a401f04abc64772cd3ab6776b0c222f4', '2026-09-24 12:29:13', 1, '2026-09-24 12:29:11'),
(494, 7, 'cc1589a811462638fe49db9da43d9d0d7108c70ee0b72f7ebfeca14491d04680', '2026-09-24 12:29:15', 1, '2026-09-24 12:29:13'),
(495, 7, '6f6ec31f82ea125d965949a9a381d083fae814174390cbf6dc596901fd789e24', '2026-09-24 12:29:18', 1, '2026-09-24 12:29:15'),
(496, 7, '41a3c756bd9e7af8af0102d030e3ec57c64d4243fdda0686e60fdd080d0994a8', '2026-09-24 12:29:26', 1, '2026-09-24 12:29:18'),
(497, 7, '0a8452d68d7296e148cc522e235daf84c536587fd1d455daffbbb6fc8a6488bc', '2026-09-24 12:29:29', 1, '2026-09-24 12:29:26'),
(498, 7, '52e1c59d92e40870739fa2afb2aef46812b58d72ed0e32a21ef14071603c8aca', '2026-09-24 12:30:13', 1, '2026-09-24 12:29:29'),
(499, 7, '3d28c2cda0dd5fe1556dc5627fe6456ec5f7f9fd6392a299c96b98c6d559713e', '2026-09-24 12:30:14', 1, '2026-09-24 12:30:13'),
(500, 7, '19ae846b67e8b6a1459406bd1c925ff86a987351e852b19d9e725f9c174be56f', '2026-09-24 12:30:16', 1, '2026-09-24 12:30:14'),
(501, 7, 'c9ddffa83cc1d99266d3b1e97ae313f63aaacffef06fb7a8d8be28c43e246cd2', '2026-09-24 12:30:19', 1, '2026-09-24 12:30:16'),
(502, 7, '3087d8254f7d8bfb56bb857c72305eb65a34c9fc9b972172a3756a87b1139d70', '2026-09-24 12:30:22', 1, '2026-09-24 12:30:19'),
(503, 7, '90a499bcab6a30d034d16d046f0dba581f7d94db86fea035c933128efe76b2a8', '2026-09-24 12:30:26', 1, '2026-09-24 12:30:22'),
(504, 7, 'c1156a8dbc1d6b5b1fb9639c3b9b55562b1e0100e98ec3baa7a9e4b78d0bf9dd', '2026-09-24 12:30:30', 1, '2026-09-24 12:30:26'),
(505, 7, '79f8b0ae5b507ce9c47775f1c1702efcaf92e26ed3a4b6e6c77f7b147c8a7993', '2026-09-24 12:33:22', 1, '2026-09-24 12:30:30'),
(506, 7, '19c9df7d1ffe8d770c0020e3c5a26b51c2d453de7acb4454c4aecfe84abadeb9', '2026-09-24 12:33:22', 1, '2026-09-24 12:33:22'),
(507, 7, '91d49df5425977c05da11c17a8d99515d751dc81035c0fef24dcb489b74b4a03', '2026-09-24 12:33:22', 1, '2026-09-24 12:33:22'),
(508, 7, '2479e4b0a3f1b0625456f8575c41459ef133114b5922fb6a1f2cc8291c80051e', '2026-09-24 12:35:25', 1, '2026-09-24 12:33:22'),
(509, 7, '8e021cee369c66461afbb08c6394833c7ca3ef93147d84973df86b06ea12a7a9', '2026-09-24 12:37:00', 1, '2026-09-24 12:35:25'),
(510, 7, '373662675a9903a4fcc7403d91571096ac5c24c44dcaa7d2eac23e32e5d2af95', '2026-09-24 12:37:20', 1, '2026-09-24 12:37:00'),
(511, 7, '733df1727fdfff7e105828ae49c7da0cbca7d0cb68ebea08624823867562eab7', '2026-09-24 12:37:24', 1, '2026-09-24 12:37:20'),
(512, 7, '21c4d3b863c5ac6fee39da00aca26c22d7f7a643c5f99c0519f1f3576aa8f815', '2026-09-24 12:37:25', 1, '2026-09-24 12:37:24'),
(513, 7, 'f72884188037f2bf559540e627b27ab14b9776cb8a993597516b3b9ef5bba004', '2026-09-24 12:37:26', 1, '2026-09-24 12:37:25'),
(514, 7, 'c2952d4cb6b67d42cc01e8c3d97725ab22757bcb9b922b75a619ed415739b6dd', '2026-09-24 12:37:27', 1, '2026-09-24 12:37:26'),
(515, 7, '93a00659d7473f614ce9f87e100b379d6e8ffa75d38762efa54b35459d2af981', '2026-09-24 12:37:28', 1, '2026-09-24 12:37:27'),
(516, 7, '8ee36913a481cb92c073cf9d3549db1662ad9297ddf355f09b51a391691d3928', '2026-09-24 12:37:28', 1, '2026-09-24 12:37:28'),
(517, 7, 'e7d4a3ef4677bc650db02a4a002fbfc4e7261e606b39dbfffcfd61b8af488117', '2026-09-24 12:37:30', 1, '2026-09-24 12:37:29'),
(518, 7, '83f30089dc76686217d9b4d9b76f6a7dd58e1238ae93a2d1ed8a240b15228975', '2026-09-24 12:37:31', 1, '2026-09-24 12:37:30'),
(519, 7, 'a42bcbd97343aad59e89c625a8db7f897ac042188509bbe40e91557ef706d7fe', '2026-09-24 12:37:33', 1, '2026-09-24 12:37:31'),
(520, 7, 'd767ae42f1d9f7231407020bdd5ce78df2cbb00065aed287276b750cf80d872a', '2026-09-24 12:40:27', 1, '2026-09-24 12:37:33'),
(521, 7, '86fd75da93a8e22636dd18f59f11b83f44c316e45594d07d01797cbcf66a9316', '2026-09-24 12:45:26', 1, '2026-09-24 12:40:27'),
(522, 7, '67e72891510d398934f943899717ab354cc607f1d283b142dab77940d2efc759', '2026-09-24 12:55:36', 1, '2026-09-24 12:45:26'),
(523, 7, '5c2d206710501bea1c46139ed2229ee029a0efe81bd8df043ac3d530e4059f2e', '2026-09-24 13:19:13', 1, '2026-09-24 12:55:36'),
(524, 7, 'f390687a6cdb6f69dd43bb924b32d51e569d8bbf5c27b4af6947f92825044898', '2026-09-24 13:19:14', 1, '2026-09-24 13:19:13'),
(525, 7, '9cf8c9122708728eae1a8bd020fadc1637e8a1290afbc736acc0121813aad492', '2026-09-24 13:22:15', 1, '2026-09-24 13:19:14'),
(526, 7, 'e04a79846a69aeea37305caa954aea658e0b75550f75ff9c5f7177dae5120b40', '2026-09-24 13:22:18', 1, '2026-09-24 13:22:15'),
(527, 7, '9fbac7a8229533f54ec78e2bfe155ac2d28f4c0cddfd213a1d7a0cd072939c53', '2026-09-24 13:22:20', 1, '2026-09-24 13:22:18'),
(528, 7, 'c0a99a68026f3917ac3fff5e5f8f15c725799efdca41ea1a65da2d73157fec3f', '2026-09-24 13:22:21', 1, '2026-09-24 13:22:20'),
(529, 7, 'ba3bc33740720f50cfa97317dda0cb153f4d8ce3f1135760934cc70ed59bcd3f', '2026-09-24 13:22:29', 1, '2026-09-24 13:22:21'),
(530, 7, '88c7bedf6db4162afb1414bf347cd594f2770acf39e18365114260a453f4d4db', '2026-09-24 13:22:32', 1, '2026-09-24 13:22:29'),
(531, 7, '58bbb421e1b1b5fb527e9806f3a9f2631d66c85f274b838e50aa7ff654b0de70', '2026-09-24 13:30:03', 1, '2026-09-24 13:22:32'),
(532, 7, 'a8e1f4907a2ee08734d857a1616914e66fc6bcfc721b1ad9bd7c8e4de1122d99', '2026-09-24 13:30:07', 1, '2026-09-24 13:30:03'),
(533, 7, '302cc40109170454a79a0522d465c5e9e16044b539c4a4c9c6d79fa8636dceea', '2026-09-24 13:30:07', 1, '2026-09-24 13:30:07'),
(534, 7, '6918b61f0e4b3c5cb186a700f00a5e7a5a9954f7f9c3fb8b7c47f3416b89b823', '2026-09-24 13:30:07', 1, '2026-09-24 13:30:07'),
(535, 7, 'b633e12a67e490e068f85b91061a5eb4371fc07c174331e2e60a6f6c4c363537', '2026-09-24 13:30:08', 1, '2026-09-24 13:30:07'),
(536, 7, '09202717e0dbec4f832580075587410325e677bf2739c0241cb41f0b32a8f67e', '2026-09-24 13:30:14', 1, '2026-09-24 13:30:08'),
(537, 7, 'd831a407479b5aa2759dc17cdb2310fd155dceeeaaf5e7ab28ded415d6ac9711', '2026-09-24 13:30:22', 1, '2026-09-24 13:30:14'),
(538, 7, 'e11095a808f9f11d8472ba7b6535756d71aa0697fef0fda24c198426b019d3eb', '2026-09-24 13:30:29', 1, '2026-09-24 13:30:22'),
(539, 7, 'd156ed3147ae5fb93fdc9a634201c13b0e0e527aa3bd5ee7e3a9f718a075e469', '2026-09-24 13:30:30', 1, '2026-09-24 13:30:29'),
(540, 7, 'd1733f95f7099e93e8862eaca363508ee8732465afb1ccb84e71143c0f35431c', '2026-09-24 13:30:32', 1, '2026-09-24 13:30:30'),
(541, 7, '50ef028c49ef77ce2b5bb71430f66bc9647d79d28f494c0d0f405c7f80c8fc9f', '2026-09-24 13:30:35', 1, '2026-09-24 13:30:32'),
(542, 7, '579c3329f1c4c707688c8da1a0fabd864f46898d1e8d695adcc7a236a74906f4', '2026-09-24 13:31:01', 1, '2026-09-24 13:30:35'),
(543, 7, 'b54810c4eadfa5a0c12123be2bfb4b3adb6860cc9ebb3f15547d6e3b74d21ea5', '2026-09-24 13:31:04', 1, '2026-09-24 13:31:01'),
(544, 7, '13a3f5e9b1c89cd68df27eb482b73c576e0d326a45f175438591b3c6bf0b56a0', '2026-09-24 13:31:44', 1, '2026-09-24 13:31:04'),
(545, 7, 'd287eecefcb6b3e8bb6c7cb78c6ba4864b8855b41ace757314d6ce71facfc9c0', '2026-09-24 13:31:46', 1, '2026-09-24 13:31:44'),
(546, 7, '6b9f52e29f3c6c31d160e3eaefdfb296b1552ba1e7d17b028c6abac2d517a6d6', '2026-09-24 13:32:13', 1, '2026-09-24 13:31:46'),
(547, 7, 'ac3d11e655708850d2970e459fc3f39ee3bf861907e770599b1a010cbb3dfd40', '2026-09-24 13:32:15', 1, '2026-09-24 13:32:13'),
(548, 7, 'bd90578b06260353518d8bfa3e187520b9b231518a1157a4b6073d3e05fe5c3d', '2026-09-24 13:32:22', 1, '2026-09-24 13:32:15'),
(549, 8, '51854d4d8283b10702cb9f523be9181bda9e2b7d640041bfe05c0c85dde352e7', '2026-09-24 13:33:13', 1, '2026-09-24 13:33:12'),
(550, 8, 'ce7b80501ea4e17dc1ebb718662859e5188277814306eb5fb00536043609a9cf', '2026-09-24 13:33:13', 1, '2026-09-24 13:33:13'),
(551, 8, 'a6368f95b961963f460e0ac9bde631af4ec4616607bf467c62379556b6e83ca0', '2026-09-24 13:33:13', 1, '2026-09-24 13:33:13'),
(552, 8, '4c7aea36fe899bda56877a1565c94f2004bcd0ac93702fd01dae9b27c6f100a3', '2026-09-24 13:35:30', 1, '2026-09-24 13:33:13'),
(553, 8, '5cadb9e8894782f723aa32a9b72bd3f35a1c2cf407e158efe3304e918064a2aa', '2026-09-24 13:45:54', 1, '2026-09-24 13:35:30'),
(554, 8, '55ff6fe8abf1072844e7fc9bf11e72aaa0bd5fbc2e03baa425157e9fd6b362c1', '2026-09-24 13:46:09', 1, '2026-09-24 13:45:54'),
(555, 8, 'e7283ff05dffd1e7aff6f4823b1bdb462a9a05083449b13c9ae868c46fa858df', '2026-09-24 13:46:25', 1, '2026-09-24 13:46:09'),
(556, 8, '41178e76f89f02d899dc5d83f8e7731ca5a40b4d547fe22372985f7b01b5ccc8', '2026-09-24 13:47:02', 1, '2026-09-24 13:46:25'),
(557, 8, 'e5a6e7bd13e0d3647d854eb0339b902f007dc393cf95ab7784d945ccd9dc7d19', '2026-09-24 13:47:03', 1, '2026-09-24 13:47:02'),
(558, 8, 'fb94b58495284cd17172df7f292d49dd4de36102f6587c27f02c0b28c8e902ba', '2026-09-24 13:47:06', 1, '2026-09-24 13:47:03'),
(559, 8, '72c32caaa51644d88c21c193afa1723ac39111833e07dd4b90dd851fa93702d2', '2026-09-24 13:47:09', 1, '2026-09-24 13:47:06'),
(560, 8, '6fb5c9434c5c0fd88a1b72980fc1f444497252636e8706b68fec7e7dc792f42b', '2026-09-24 13:47:12', 1, '2026-09-24 13:47:09'),
(561, 8, '4e118be9685cb0ffbdf3e988654f82a21b5a6213b845e964c6582537d40e2b93', '2026-09-24 13:47:13', 1, '2026-09-24 13:47:12'),
(562, 8, '3a7abe356d4bf8d915a59c9d95f5ee0572df82c2f6ed5b6c090cc05ff8251395', '2026-09-24 13:47:17', 1, '2026-09-24 13:47:13'),
(563, 8, '2dea26e532ec74bf0e3d62f43953cb2e811ba8066306c9f73efd7f55d60f640c', '2026-09-24 13:47:31', 1, '2026-09-24 13:47:17'),
(564, 8, 'deff13f164f40fc635cdbd42335d4cc95e37de821734ddba668d1114abd2b803', '2026-09-24 13:47:53', 1, '2026-09-24 13:47:31'),
(565, 8, '842d8464aba4b44794b0c08fe4676230c6ce6c8186a9a932922bddfc00339653', '2026-09-24 13:47:55', 1, '2026-09-24 13:47:53'),
(566, 8, 'd553c315aaed0132702bd93e6bec7dbabd473d91d411df888cc8252c5d4dc97c', '2026-09-24 13:48:14', 1, '2026-09-24 13:47:55'),
(567, 8, 'ae21f4dbb95ff4f3f6978a8d71c7166cd70ff0eb9b39aa099ceb7ca692deb822', '2026-09-24 13:48:15', 1, '2026-09-24 13:48:14'),
(568, 8, 'e4e02dfc81d28980e2345b15bb27139e8de4c3b7905268f7005314a7e16a14b7', '2026-09-24 14:16:49', 1, '2026-09-24 13:48:15'),
(569, 8, '0db18aca18fb251d64c4b0316a7d6b2c1a983b8641f6d24b84a0780d763ba442', '2026-09-24 14:16:50', 1, '2026-09-24 14:16:49'),
(570, 8, '60a5d1444e265ac2084786ba48f495c7342dd8cc47b81bad60895e1401554ff4', '2026-09-24 14:16:55', 1, '2026-09-24 14:16:55'),
(571, 8, 'c3d24aecb9f77c28719f5f039116d07f21509e0abce5cfd2642b6c246f8ab68c', '2026-09-24 14:16:58', 1, '2026-09-24 14:16:55'),
(572, 8, 'eeef2ddfa94e70fcce8db3e3384c666418dff8fc1e9e2bc6f8b9313a65d60388', '2026-09-24 14:16:59', 1, '2026-09-24 14:16:58'),
(573, 8, '0338c3d7739d0fff2fcdffb7e99f773f7eface54386925cf58ea11f525c77aa3', '2026-09-24 14:17:52', 1, '2026-09-24 14:16:59'),
(574, 8, '906ad1be4b1fefd1f69b875d37540ff6a1fb7d3fa07a08e4e1fac2f5dbb5e58d', '2026-09-24 14:20:46', 1, '2026-09-24 14:20:46'),
(575, 8, '1dfe869fdbc25dfc2c5c1a2fd41d4e04d4abbc574abf9c604eb360f88fe98308', '2026-09-24 14:20:49', 1, '2026-09-24 14:20:46'),
(576, 8, 'bcf86b380253e000d340cb7980b79b92371f8d68f6c29ba945445d7a2a8377af', '2026-09-26 05:51:32', 1, '2026-09-26 05:51:31'),
(577, 8, '14ace3b60cd5ff0a262b51665eebc6f499b5e9e61d1ff4c1c9ac72149cdd69a6', '2026-09-26 05:52:04', 1, '2026-09-26 05:51:32'),
(578, 8, '81e4ffa2b60ef3bcb0dc91bc0d593574b9940eb063524b119d381829a6a49df2', '2026-09-26 05:53:28', 1, '2026-09-26 05:52:04'),
(579, 8, 'd4970e45b8f86e3a247aa6558ac2552d15a92e92ec6bbfd3b8b2646c53d8fdca', '2026-09-26 05:53:45', 1, '2026-09-26 05:53:28'),
(580, 8, 'fa1e793da869302db07b1214a456f7a40a335febc989d0b45962ec25234805a5', '2026-09-26 05:54:35', 1, '2026-09-26 05:53:45'),
(581, 8, '40fa99cd9fcdec348a402c85a6cc3418be423fdecaddcf34c12e6c7bb2188df3', '2026-09-26 05:55:07', 1, '2026-09-26 05:54:35'),
(582, 8, '6d3a1a4bd833b12a2e77660b1de621e87d591ea36e9bb3361309fca3ed503194', '2026-09-26 05:55:20', 1, '2026-09-26 05:55:07'),
(583, 8, 'd259d9a4e8592d14a271fdae889f083729db129235be20f84f1bbee98337a1d6', '2026-09-26 05:57:21', 1, '2026-09-26 05:55:20'),
(584, 8, 'd65773ccf5ed42286f862495b8078c79fcdc748aa77f958228a1974216ecba1b', '2026-09-26 06:00:42', 1, '2026-09-26 05:57:21'),
(585, 8, '7b6381b72c75906a3fcccc8ab313632c9e12b2f591289eeef789e1259dc7b33f', '2026-09-26 06:00:47', 1, '2026-09-26 06:00:42'),
(586, 8, 'fc5d1104b828bac3ab59a9ccb71b361f8876d2cebba001b493461de3ef3616f3', '2026-09-26 06:01:02', 1, '2026-09-26 06:00:47'),
(587, 8, '84d2f0be10e8a143c7a7f7c5de0cffc6b84032ab728cfdab9f08cbf14c87be79', '2026-09-26 06:01:06', 1, '2026-09-26 06:01:02'),
(588, 8, '5cd813e4f8cf8b8d78960c6c4bbfc5820e586e952986acdddeaa63237d5be18a', '2026-09-26 06:01:08', 1, '2026-09-26 06:01:06'),
(589, 8, '2fb6ab5d988396e86bedd48efb41edd589d86b4994d1a1051d3a7f048ba0bad1', '2026-09-26 06:01:17', 1, '2026-09-26 06:01:08'),
(590, 8, 'f0b75a5ab6bf191109fcec8fbe8c4fff0651a34af40e3189c44b02d898e3e88d', '2026-09-26 06:01:46', 1, '2026-09-26 06:01:17'),
(591, 8, '740ad4215133e6837e2fe715ed4847a4ee90411ac300ebe024064914ac79a0d0', '2026-09-26 06:02:02', 1, '2026-09-26 06:01:46'),
(592, 8, '1733306a2ab30d3a65d3e359cf01efe9d61ec11a34dd68342acde0518fe93656', '2026-09-26 06:02:07', 1, '2026-09-26 06:02:02'),
(593, 8, 'af9a0e3d8c06b5a63c1323a713a73b6a7ed4392492031c566fafad21c937a203', '2026-09-26 06:02:22', 1, '2026-09-26 06:02:07'),
(594, 8, '90fac4d7fd23d6b48b1d95a3b28a1b84110d71f087563ebe6897fa447badebbc', '2026-09-26 06:02:55', 1, '2026-09-26 06:02:22'),
(595, 8, '58415d945047e31477e904114c1a051a07f4cbfa87ae031e197bd572b8ad99e6', '2026-09-26 06:05:39', 1, '2026-09-26 06:02:55'),
(596, 8, 'a911bb9a047da2ff46fcfcd4a845dc783070110f968aeaf90160ec8ee70b9678', '2026-09-26 06:05:49', 1, '2026-09-26 06:05:39'),
(597, 8, '15b45d799bbc3fd1eb726b50a1876bc658bf1aa13d9687bf73eefbeb4a623bd0', '2026-09-26 06:06:06', 1, '2026-09-26 06:05:49'),
(598, 8, '14d3518258b4d709dc013fd8e16ec2b797d1508fd05c107609c92174531d2d4f', '2026-09-26 06:06:08', 1, '2026-09-26 06:06:06'),
(599, 8, '7b8e23b6490cf94bd5d458e085599b3ef7ecf544ad6157efa7f01c8ac9250c22', '2026-09-28 11:10:26', 1, '2026-09-26 06:06:08'),
(600, 8, 'e8981f63bb756168a7a9ebb603598f412c08ac1fc8b586c38748b9534f10de15', '2026-09-28 11:10:26', 1, '2026-09-28 11:10:26'),
(601, 8, '2ee019c30dc992810c90cf8dcf500495fbd7c0e3da3df20ceaca650e7e550e15', '2026-09-28 11:42:13', 1, '2026-09-28 11:10:26'),
(602, 8, 'cb9a8c1913931badd7569a5aa763bbd90a2f7e65ebe8deab16560c6169cdf640', '2026-09-28 11:57:26', 1, '2026-09-28 11:57:26'),
(603, 8, '52c981e3f12b47e86aa0215a34c41ef12fb784e518e094a60bce29d735edfc84', '2026-09-28 11:57:43', 1, '2026-09-28 11:57:26'),
(604, 8, '7ee9e0b5f5aed6ac24041b157d3f33861e4521e115f1b42502375c12d76c08cc', '2026-09-28 11:58:38', 1, '2026-09-28 11:57:43'),
(605, 8, 'cc0c4a681e7f39c115bca51734c4bf2f981f22b6021efc10543ce7abede5ec56', '2026-09-28 11:59:00', 1, '2026-09-28 11:59:00'),
(606, 8, '1d6aed5fe6279c132d8fae18560ab6c31f87d3c7f77889d035a80b596f9772f3', '2026-09-28 11:59:13', 1, '2026-09-28 11:59:00'),
(607, 8, 'e65aebd3b77fa2d830ad7437b4eca9a8c3e5132340eb662f3b8840b9c8829427', '2026-09-28 11:59:52', 1, '2026-09-28 11:59:52'),
(608, 8, '4e645b0c697623062943f4dda32b2629b8e9fd29df2ffc9c607cb2080cd33f9f', '2026-09-28 12:12:36', 1, '2026-09-28 11:59:52'),
(609, 8, 'f22c3681602dff8cb8ea2113975add869c1d81bb059f8dd50fd6939402d243d8', '2026-09-28 12:12:37', 1, '2026-09-28 12:12:36'),
(610, 8, '984fca7a0b977cc0a5a1a1dbe4d3c8611bf137302e62bae520897579b505d97b', '2026-09-28 12:24:03', 1, '2026-09-28 12:24:03'),
(611, 8, 'acb909fc5c4de2d7b35a202594a0b545142c75b7a66824535df3f6845d4b715e', '2026-09-28 12:24:09', 1, '2026-09-28 12:24:03'),
(612, 8, '6230318a4737932a8b8523ee835046eff9275861ea25a0572522a44b373b73fe', '2026-09-28 12:24:11', 1, '2026-09-28 12:24:09'),
(613, 8, '073c7d9243f513d61db1f3863958a19a9f86ddbd886fcb61e4a29d57ccfcd13c', '2026-09-28 12:24:14', 1, '2026-09-28 12:24:12'),
(614, 8, 'd3820fe716072749113bef6e75f16e0041242c7c012d758cef7e75d4134370fa', '2026-09-28 12:24:16', 1, '2026-09-28 12:24:14'),
(615, 8, '22a99f60b366362cdcc96f74e97f6dd5374565c93cff786a1b5c431de88efaa5', '2026-09-29 12:01:17', 1, '2026-09-28 12:24:16'),
(616, 8, '39529da3c8999895f8cee9f35daa2ba6d63a453800f559e87daeb6c32b5b2c7c', '2026-09-29 12:01:17', 1, '2026-09-29 12:01:17'),
(617, 8, 'c115dc5c69e0abab26d02c79cd57d6c6d9886fa7441e5a008c8c5864882588d6', '2026-09-29 12:27:55', 1, '2026-09-29 12:01:17'),
(618, 8, 'c9ca792a9c7f12311fc5185b2bb04c2776fd1031391aa299dd6526b366094c3a', '2026-09-29 12:27:57', 1, '2026-09-29 12:27:55'),
(619, 8, 'f2533a80abecbdf132a427780bd744f5737ba757b4ee451067ba846dd389a386', '2026-09-29 13:09:30', 1, '2026-09-29 13:09:29'),
(620, 8, 'f72d95cda402f7d3afd806417415c1c0ae5a019a5f15576f64548357573e716b', '2026-09-29 13:48:32', 1, '2026-09-29 13:09:30'),
(621, 8, 'ccd3f5eca4076ac4ce4acccc6e3434a8da56b786157e5eff37f075a019bde65e', '2026-10-01 12:02:42', 1, '2026-09-29 13:48:32'),
(622, 8, '1267aed2a46887ab7785ccc942c044edad7e6918a8669fdb309dd5d288c86840', '2026-10-01 12:02:43', 1, '2026-10-01 12:02:42'),
(623, 8, 'e2ba36dfa9c9b823a27ea6d9e8692967f7cb2adf75e5a13bfec4f79a6fce8937', '2026-10-01 12:02:46', 1, '2026-10-01 12:02:43'),
(624, 8, '84e33d0e0fc9fdfda33fe6a9d393c13aa79f126b7df76e492bda849d486a8c92', '2026-10-01 12:04:07', 1, '2026-10-01 12:04:06'),
(625, 8, '9d47bcec42e1813f84150e22783945e45b1e3b3f4a63fad54bf8f070660a0955', '2026-10-01 12:04:09', 1, '2026-10-01 12:04:07'),
(626, 8, 'fa7dd814b37e0ac275c3f029889d7424e384d51ea1ce3a96178ad951fb2f201e', '2026-10-01 12:10:45', 1, '2026-10-01 12:04:09'),
(627, 8, 'c497074c218848eccbcefd5c108d34070f1d2f59eef52008eeda7b37e27c1fe3', '2026-10-01 12:31:11', 1, '2026-10-01 12:13:08'),
(628, 8, '599b3c47a7f592d0bac8c1164318936778758c5cf9a7359167ef0dc7751b0ffd', '2026-10-01 12:31:24', 1, '2026-10-01 12:31:11'),
(629, 8, 'e6c6798816a7765aea2baa3d40dc33cb0430925cd953bd38309ca981b7a75483', '2026-10-01 13:37:38', 1, '2026-10-01 12:31:24'),
(630, 8, 'b2e6e67f237752323cc242eba829a884235501b0c02436988ad1bdf49be334e8', '2026-10-01 12:32:07', 1, '2026-10-01 12:32:06'),
(631, 8, 'c9c35558eb19d3e8c32f2a3fca4aed9b2146d396658f96931adb57ecd5722ac3', '2026-10-06 11:30:37', 1, '2026-10-01 12:32:07'),
(632, 8, '8317f20fbe5b61cb90e0a1bd837d8418d09c2bf8ad09892c713410f2a1f35d7c', '2026-10-08 13:37:38', 0, '2026-10-01 13:37:38'),
(633, 6, '107b1edee26cf420e36a4835198fc93f2ea3c67e73eaf736a665515f2b764771', '2026-10-09 14:17:39', 0, '2026-10-02 14:17:39'),
(634, 6, 'b46640ac8522bef00ab8076a7f721a474b3cc5089f7a47172b8e66e6718e9e39', '2026-10-09 14:23:02', 0, '2026-10-02 14:23:02'),
(635, 5, '9bd114978b15cdc4683ede3aa92b447793f296680230428c1f29e1b0c0f1a203', '2026-10-09 14:27:59', 0, '2026-10-02 14:27:59'),
(636, 5, '255b43995dc32142d4cbda114a20da68064b7bcf33b1e3ea83a995c95df808a4', '2026-10-09 14:28:38', 0, '2026-10-02 14:28:38'),
(637, 5, '44b49a8554cc4338c35b1f6b7a2237fdb89431304e2c47d0d9b9800b7022494f', '2026-10-09 14:35:44', 0, '2026-10-02 14:35:44'),
(638, 5, 'c2c2f43273d90c61b5fbb5927f6aba0dc66ea2f7714c4803fb96729f3655326a', '2026-10-09 14:36:21', 0, '2026-10-02 14:36:21'),
(639, 8, 'dee885c85e414b0d3992ab54219cee4799aa0bc5fe6900e9a9cde63fe1a041b4', '2026-10-12 14:21:33', 0, '2026-10-05 14:21:33'),
(640, 8, 'f1e52a3ac73a0c8b17ee3bd4a22a90bc56c8f981cff432d95d66114235b61f38', '2026-10-13 11:30:02', 0, '2026-10-06 11:30:02'),
(641, 8, 'a7d9e2b6a9b8b80ad14188641249ee2bf55f44c9a611cebbcfaaa5bf710564af', '2026-10-06 11:30:38', 1, '2026-10-06 11:30:37'),
(642, 8, '85c7e6a5e43e6229fca161df9712859a110aa6abfa9b6132e0143eb1fe6661df', '2026-10-06 11:30:38', 1, '2026-10-06 11:30:38'),
(643, 8, '376afe7d5ba8447127f37e626df469b11bc5f5a4e5f6a4ea2c4da6630b4d553a', '2026-10-06 11:30:39', 1, '2026-10-06 11:30:38'),
(644, 8, '480090e0f17eb1371ac26bfc416e38a8a0b0d22480deb80b0e4778e300636275', '2026-10-06 11:35:14', 1, '2026-10-06 11:30:39'),
(645, 8, 'e06edebf2b29cf4a25334ffbb6e979f33931af47608f73ac6b1aa924c4f3dd3d', '2026-10-06 11:36:05', 1, '2026-10-06 11:35:14'),
(646, 8, '5299b7b9a8e0338ee064d5e8c2a8aac47a5d11e1f40732c699a82eafd670e88e', '2026-10-06 11:36:12', 1, '2026-10-06 11:36:05'),
(647, 8, '916bcae9303a79afacabc077284a1ee09c5d66bef72354f4f814c6567746cdaa', '2026-10-06 12:33:27', 1, '2026-10-06 11:36:12'),
(648, 8, '8097fb6985463a1bee6d5dce5afc4014b6d00ddc4210ebf3cdf4da9180d8e976', '2026-10-06 12:33:37', 1, '2026-10-06 12:33:27'),
(649, 8, '41c59c027c5c7cae84e80d6875708b16e75b184f14ea531d5bdbe51111e1a99b', '2026-10-06 12:33:58', 1, '2026-10-06 12:33:37'),
(650, 8, 'facdfce85b4adfc0a8de43d9a0682959e1e02e7fddaaedf780e96f04fc757a1d', '2026-10-06 12:34:18', 1, '2026-10-06 12:33:58'),
(651, 8, 'c2b4cf46585b1df6401e1d9e004e9911abee5933df72900be7a8088207ec1f29', '2026-10-06 12:34:29', 1, '2026-10-06 12:34:18'),
(652, 8, '3c6d7dcbf015b8778989cf2c0c22c9fbd3220aa87b66c6e22053eddd429fa2fb', '2026-10-06 12:36:34', 1, '2026-10-06 12:34:30'),
(653, 8, '3ac804fe4a143b5eb6e3a53d470767a9d07a9f3399cd052b30b25a1f6bd8dafc', '2026-10-06 12:36:38', 1, '2026-10-06 12:36:34'),
(654, 8, '9763a1444886b44c164984fd80d3ad4e1f69d6b7a45fa8e65a42e540b1eaa29c', '2026-10-06 12:36:46', 1, '2026-10-06 12:36:38'),
(655, 8, '711d3d4a5761bbd5644d935b837d2aa056eabe04e15e0ba2d274f90750870009', '2026-10-06 12:36:58', 1, '2026-10-06 12:36:46'),
(656, 8, 'bfe4b0bc4c3528102155e6b6cea6d8a56fe44347b1f7b5dd8fcd6439c5206e6e', '2026-10-06 13:40:20', 1, '2026-10-06 12:36:58'),
(657, 8, '911a1d4a102d894bbb4e87387cb3d20c46395e61ea01010fbb0bb599cc7fba9c', '2026-10-06 13:40:31', 1, '2026-10-06 13:40:20'),
(658, 8, '049e934d787ee4550fddeea31b8ee33ec43c8071a98b78e024f81fe3b6df384f', '2026-10-06 13:40:54', 1, '2026-10-06 13:40:31'),
(659, 8, '91f23b078006a01f4285a0681403656b6f40e4383960d0f9ba62ffdf4c459d22', '2026-10-06 13:40:57', 1, '2026-10-06 13:40:54'),
(660, 8, 'bd16a2107eb7d09fe0c92cd9db03321a17bcbba074bae08a61985b13871c82dc', '2026-10-06 13:41:15', 1, '2026-10-06 13:40:57'),
(661, 8, '656be7520ad520e5e3647c8f59cb08f21924c3b24456fc6712dc02c70f2796e1', '2026-10-06 13:41:30', 1, '2026-10-06 13:41:17'),
(662, 8, '287fa742cbee53ef40a7832c398e95f2bbfc003c50b88cce5188498ebfefa8a6', '2026-10-06 13:41:40', 1, '2026-10-06 13:41:30'),
(663, 8, '3b3d4ec2513606b9f2cc2250c3daa2c982db042e8b538232e07bd5174c5be7bb', '2026-10-06 13:41:44', 1, '2026-10-06 13:41:40'),
(664, 8, 'c94da04843b8c2a3887ce81af51f80a1b2ab88db941a321b5d0dc959189ea10a', '2026-10-06 13:41:52', 1, '2026-10-06 13:41:44'),
(665, 8, '959c5a8e8afdc0a6bded2d916834123bf0f55d976092bb613bb6b20428658686', '2026-10-06 13:41:56', 1, '2026-10-06 13:41:52'),
(666, 8, '39d137275f3028e18f897bf779916cb26fb06eff9a80c4392c2f4c12d7f844a7', '2026-10-06 14:23:26', 1, '2026-10-06 13:41:57'),
(667, 8, 'c48323667201f75a896b6b275e7889e695a8565cc206c6905b7eeb5833e9d2d3', '2026-10-13 13:48:00', 0, '2026-10-06 13:48:00'),
(668, 8, '8e37edeb2d74173b59157755ed1126d41a013bc9fcbc45c3f6f9698c55237d2b', '2026-10-06 14:23:32', 1, '2026-10-06 14:23:26'),
(669, 8, '5811fe58feee6f4c429b3a6abb7fb98ac3e6da29687d8e1baa899f3785ca90a8', '2026-10-06 14:23:47', 1, '2026-10-06 14:23:32'),
(670, 8, '0d7db77416c3a5a3e03eb6322b6a8f725078bbdf96a190678e569c233710f027', '2026-10-06 14:23:59', 1, '2026-10-06 14:23:47'),
(671, 8, '94ef92985e2e98833fdc86ec038eb2f564b89545e99076b4e5c03e585c7ea07b', '2026-10-06 14:24:04', 1, '2026-10-06 14:23:59'),
(672, 8, '6ce8d7e163139036bde94154fb290d7121fa9257740f6bb3a3f7385727552c6a', '2026-10-06 14:24:32', 1, '2026-10-06 14:24:04'),
(673, 8, '81e6a177a416fdb53c90151d58732e15c0c9555f6cf5c11e62d2e7ad39a89d08', '2026-10-06 14:24:34', 1, '2026-10-06 14:24:32'),
(674, 8, '04c0b51d0ba95b444af13b30c49046e50a211e265f4ded40e04c1bcbb0724c4b', '2026-10-06 19:50:13', 1, '2026-10-06 14:24:34'),
(675, 8, '1578770bcdf5a2e01b6a608ab5f5ee10f1ef4db51bc78736acd0dfd41939725a', '2026-10-06 19:50:14', 1, '2026-10-06 19:50:13'),
(676, 8, 'a58446b86f136a4e5572fbc6c14223eaeffb8f4ddb8e55d31670d0672617dbe7', '2026-10-06 19:50:17', 1, '2026-10-06 19:50:14'),
(677, 8, 'f86895498621c6449b356f207b682d38bb6689f2e9e6bb18022baf19951e294f', '2026-10-07 07:50:34', 1, '2026-10-07 07:50:33'),
(678, 8, 'f3476558c2dcc1b626758549dcbe96431dfc2cd88a3a6ad856f674e157722e28', '2026-10-07 07:50:39', 1, '2026-10-07 07:50:34'),
(679, 8, '61c78cc7962f5e7916ebbb0daf1445d7328cb6c522a5099d7bc6c894cf645572', '2026-10-07 07:50:57', 1, '2026-10-07 07:50:39'),
(680, 8, '4b2d2eca50336fa5c702384851285142586942a7d761e82b157b73828be315e2', '2026-10-07 07:51:12', 1, '2026-10-07 07:50:57'),
(681, 8, 'cfa43b85928fc3232d3418b27b16f7beef902d4ba3c3c08ef6d56650fe01146f', '2026-10-07 07:51:16', 1, '2026-10-07 07:51:15'),
(682, 8, '8331a81955cf16c8e20370007007d5540a0abd201ff9502dd1f64d30744fc5bd', '2026-10-07 07:51:20', 1, '2026-10-07 07:51:16'),
(683, 8, 'ccb6d8acb2576e8981f737ccc38e7ecd24bc22b0881a557d857788e7c36c47eb', '2026-10-07 07:51:37', 1, '2026-10-07 07:51:20'),
(684, 8, 'd9300717438feb5c8e24f665c3fb43ca902f60757e7aec95a03248cbd93b6a76', '2026-10-07 07:54:42', 1, '2026-10-07 07:54:42'),
(685, 8, 'b6c8cd3fb4b501a75ee6deb5db68efce9ce5fb9311d13667941556898d2df34a', '2026-10-07 07:54:55', 1, '2026-10-07 07:54:42'),
(686, 8, '423f51b53b972e47998959eb17fd130ddfbc4216faad439ffe0ae0ea907847be', '2026-10-07 07:54:58', 1, '2026-10-07 07:54:55'),
(687, 8, 'bf517132a61a911bce1babd998a76cfa1616ac5d7438e3b50ceb5287615a43b0', '2026-10-07 07:55:00', 1, '2026-10-07 07:54:58'),
(688, 8, '2a3c4dfcdc61f189158d371368e86acba750834ec9e07cdfc642278ae8b23d8e', '2026-10-07 07:55:05', 1, '2026-10-07 07:55:01'),
(689, 8, '53680bda2796b635ae2878b2e56f2e9de1eec38b1d3df33edc6a76614122cf72', '2026-10-07 07:55:18', 1, '2026-10-07 07:55:05'),
(690, 8, '849ab54bcd6eee843476b5a6a38b45bf4c3af8e399bc83ab929809e172281cb6', '2026-10-07 07:55:35', 1, '2026-10-07 07:55:18'),
(691, 8, 'a97800a4e889b62d2ff43a4a41dad18c3637edc3ae864a6e848e0d438cbdc3e6', '2026-10-15 11:53:27', 0, '2026-10-08 11:53:27'),
(692, 8, 'd237b76d7bc621fe5ef60a0ccb619d669a40ff3f45e20444664eba8ffa987e7a', '2026-10-15 12:16:23', 0, '2026-10-08 12:16:23'),
(693, 8, '86925718675ade2b53abd0bd6543ee47c5e0588f519ec169caadddaee9c4911a', '2026-10-08 13:16:33', 1, '2026-10-08 12:53:20'),
(694, 8, '504ffe434ee03583c9f01614073c5f82d23f1fd7f2541e3f8f44c6c4cbee0f0c', '2026-10-15 13:16:33', 0, '2026-10-08 13:16:33'),
(695, 8, 'f3660a58935a8c2b7460ee9a85f2a1b97a41da6bde17532a7dec45f7949c3c99', '2026-10-08 13:18:56', 1, '2026-10-08 13:18:55'),
(696, 8, 'f16944b6050fffbd619c947774110cd4d4fca4e98b9ea10b828184e9e8202910', '2026-10-08 13:23:15', 1, '2026-10-08 13:18:56'),
(697, 8, '5fdce2c5799a9de90e89eefb1624e44c8611be42f4d848c72f82d2ad875bb163', '2026-10-08 13:23:18', 1, '2026-10-08 13:23:18'),
(698, 8, '054fef3d46e7eac08be724c8c91c5b37aefa63c9611a18e6911a8fee7252abca', '2026-10-08 13:23:31', 1, '2026-10-08 13:23:18'),
(699, 8, 'c976714ebe1752d0615c737060c3f9d511957ab96bdbcb24e08e962c3c1a934f', '2026-10-08 13:23:38', 1, '2026-10-08 13:23:31'),
(700, 8, '723d0ca2bf516637e1167301595f49bc27dbd389333c80ecd90e419d0f936cc9', '2026-10-08 13:23:42', 1, '2026-10-08 13:23:38'),
(701, 8, 'a422af8031e9d6b83a910b71ca54f6edbbdfe5862526e0cd6d55ee7487f9ba14', '2026-10-08 13:23:47', 1, '2026-10-08 13:23:42'),
(702, 8, '7ec6b8832acf9da5d3871ec4cb0096d11fbed76aeea9a9633b87dda24445b25e', '2026-10-08 13:23:50', 1, '2026-10-08 13:23:47'),
(703, 8, '7a250a1d8d31328febfdd64b4623e24e56a49779806e7bc79aed0dab2e87f7e1', '2026-10-09 11:07:12', 1, '2026-10-08 13:23:50'),
(704, 8, 'e69c5f4557f021af4fca052f45503360a0c6030dfc481f44bf2d6d5fdf9a2dc3', '2026-10-09 11:07:12', 1, '2026-10-09 11:07:12'),
(705, 8, '5ce92a8d673ad55a09f3da0e52d22cd0aa7ecd7536939d1d28206f3227334ff1', '2026-10-09 11:07:13', 1, '2026-10-09 11:07:12'),
(706, 8, 'df92cceb35b3f56559da4d57635cbf78c6ba060f884683937142215de7e94ff5', '2026-10-09 11:07:13', 1, '2026-10-09 11:07:13'),
(707, 8, 'e88e6544bf3de081355af5114478b2bdaf84a0941fc73723fd5c08a76d5a90b3', '2026-10-09 11:07:17', 1, '2026-10-09 11:07:13'),
(708, 8, '88c70611ba6b4cf547ba36cc7c324094731e560e5cf3cba8c1b47172d9a5846f', '2026-10-09 11:58:35', 1, '2026-10-09 11:37:36'),
(709, 8, '41430026c9f2810e2fad7022875843e0734311924dfbf12242bae29f90885c08', '2026-10-09 12:38:15', 1, '2026-10-09 11:58:35'),
(710, 6, '20079951479e92cc795b7943bbc20129d75b638497d9ec6a60a87f8f741de125', '2026-10-16 12:00:39', 0, '2026-10-09 12:00:39'),
(711, 6, '1238a06d6704235d7e821ffaade58915cc2f73d7fe8976caf3979e46c9ee2be3', '2026-10-16 12:00:59', 0, '2026-10-09 12:00:59'),
(712, 8, '2607957b7a04c9529924ee0b2e1ef4e922a31afe530a0565a9790198e5380a4e', '2026-10-16 12:38:15', 0, '2026-10-09 12:38:15'),
(713, 8, '598265006eedd4aa9589d38d757d33d481f4258b9e3b4f14b4f9f6e95bb950ee', '2026-10-09 13:02:25', 1, '2026-10-09 13:02:24'),
(714, 8, '80541baf333267c0cc4d8effeb601025dd22a3b0dea9f917aff3bf8ce249baf6', '2026-10-09 13:02:33', 1, '2026-10-09 13:02:25'),
(715, 8, 'fe6db99d78ebf27fe8a170e09f45e2c6bb69273b62bb58fed8a17abbd686387b', '2026-10-09 13:02:44', 1, '2026-10-09 13:02:33'),
(716, 8, '694da34f5d520a1694d259c2e24d2ee2c707cc9aa4736937aeff327e807aa629', '2026-10-09 13:02:55', 1, '2026-10-09 13:02:45'),
(717, 8, '12a5c1d5adaded183a500aadc9c779743d332f43f7471e488ba5a2b83844ba17', '2026-10-09 13:03:10', 1, '2026-10-09 13:02:55'),
(718, 8, 'b749b4c126da789de9761a47fcc6c083b73b6ce9baf90c4f4924390ea080d4e4', '2026-10-09 13:03:33', 1, '2026-10-09 13:03:10'),
(719, 8, '069e1cdaf83191b4c6c1512f9d5fa09eaaed2ebfbe7411fda32e0a18a41966a6', '2026-10-09 13:03:38', 1, '2026-10-09 13:03:33'),
(720, 8, '2490c7fdd5af08f6e39f03cc6d722db5cce2b4928439cb02e2a924395a9bf4eb', '2026-10-09 13:03:44', 1, '2026-10-09 13:03:38'),
(721, 8, '3af606f4faee16bc80c0e5341b73bd3b7fda98c8c2c06a6a4dc3f30af5748493', '2026-10-09 13:03:55', 1, '2026-10-09 13:03:45'),
(722, 8, 'd632865e68619a287181b3d6df1d6948f7a3249b266d26bfdbdadf43864c2c5c', '2026-10-09 13:04:02', 1, '2026-10-09 13:03:55'),
(723, 8, '7b2701a005ce54a314519c7ccae0e08ee5985a104b37b3eb88cc39b4d50259d6', '2026-10-09 13:04:15', 1, '2026-10-09 13:04:02'),
(724, 8, '6bcca137bfd9af002d10b654d99ec7f47a80de226a3219f5cc29a795fafc1b27', '2026-10-09 13:04:18', 1, '2026-10-09 13:04:15'),
(725, 8, '3d471bee2239f697076c4cda322062e978c7913b5d390df85ac51195eaf751a9', '2026-10-09 13:04:24', 1, '2026-10-09 13:04:18'),
(726, 8, '8b8d05ca0a733cabc726ecdf73fe5f27788c5fcbbc926ec82bc3e106d1ae705f', '2026-10-09 13:04:50', 1, '2026-10-09 13:04:25'),
(727, 8, '44e454a80f043d7126e1dc11fb2114d94ac938363e3439342e5bbc969c0811f7', '2026-10-09 13:04:53', 1, '2026-10-09 13:04:50'),
(728, 8, '341585b4000b01c16e6dbc6912b9946b6cac717ea49586ef716e36588d2ab640', '2026-10-09 13:05:00', 1, '2026-10-09 13:04:53'),
(729, 8, '49028cbc7068c74e728dcd602f9d804ab8b7bc8eb23b8f366b952fde598e61b4', '2026-10-09 13:32:21', 1, '2026-10-09 13:05:00'),
(730, 5, '9c29ccc58ad36f7a7fccfd361c623e57eb8de490e48d22a0c7b541fe77f9575c', '2026-10-16 13:19:34', 0, '2026-10-09 13:19:34'),
(731, 6, 'b0be574da4b6896d5e88a6a2d5cb37c2101863a766e24a42c4e347dcd1d6cbdb', '2026-10-16 13:19:36', 0, '2026-10-09 13:19:36'),
(732, 7, 'dd851785dff4fd1c9d9192c1bd42d2a5e28180a999efc8b893933b40c45e738e', '2026-10-16 13:23:25', 0, '2026-10-09 13:23:25'),
(733, 5, '9225cb22fc9a16c2bb737b4ebb22af149ed7f738efd535a5ea90de70b9c4fd72', '2026-10-09 13:33:36', 1, '2026-10-09 13:33:36'),
(734, 5, '0f84a605617a13ee53918dbed8251c8cd165f16fef764fb475b1b38ac989453b', '2026-10-09 13:33:51', 1, '2026-10-09 13:33:36'),
(735, 5, '7ef75c6a3f7c91184718c700810b4375dd32a6b50596dd1d1e89c5dfbdfdbd6f', '2026-10-09 13:34:00', 1, '2026-10-09 13:33:51'),
(736, 5, 'bbf88e592786e97e6f363e4c3fd6d1b16e1c767eb799d230d5d11b5550b7304c', '2026-10-09 13:34:05', 1, '2026-10-09 13:34:00'),
(737, 5, 'd83ea9cb97cd123151d8da05e081cbb7bef30649d8b9280e9582031626f30e54', '2026-10-09 13:34:18', 1, '2026-10-09 13:34:05'),
(738, 5, 'cbb57c8e7cde53dd91108761340a93f669a23e93a91bf595831477647774eb8a', '2026-10-09 13:34:21', 1, '2026-10-09 13:34:18'),
(739, 5, 'abf97c37ebe43287d343efcf68e32594152f5267fac52b32bad5343f304d5475', '2026-10-09 13:34:39', 1, '2026-10-09 13:34:21'),
(740, 5, '1746f1be3c3b3eb193b5b81aac6f18f2bf7c97df0a37df3a4193ff3fd6d4bd1f', '2026-10-09 13:34:45', 1, '2026-10-09 13:34:39'),
(741, 5, '7b40375e173e0d6a43798b41ae6f1402234ae3cc26cb4029b3b09da4460be168', '2026-10-09 13:35:40', 1, '2026-10-09 13:34:45'),
(742, 5, '4d7f4c5f68c693ad69327d3b4e773202e2e5975ff47423adbfa4d2fff69b829b', '2026-10-09 13:35:53', 1, '2026-10-09 13:35:40'),
(743, 5, 'c55c033841aac76364ad03d9133275ee9ed91c3b125e07609bb90ee6ce188754', '2026-10-09 13:36:00', 1, '2026-10-09 13:35:53'),
(744, 5, '5dddd26d82ae568b8f9b2a8d7b631241367976cbcf02dbeca48cb4caf4d992fc', '2026-10-09 13:36:04', 1, '2026-10-09 13:36:00'),
(745, 5, '44a86c70e0a3112fb3b28b23a23cdd2510b7dba41712349915807c6369ef6b49', '2026-10-09 13:49:52', 1, '2026-10-09 13:36:04'),
(746, 5, '7e915afb64683247a3a776f28180aed08018a0aac3fe996fefccb3c3510fab61', '2026-10-09 13:59:15', 1, '2026-10-09 13:49:52'),
(747, 5, '75c5963d2cfde2b0159164a771626ebe0cac0962a1ddfdf80f2e0abd79887c51', '2026-10-16 13:54:28', 0, '2026-10-09 13:54:28'),
(748, 7, '2389765141b63bf5664720276a163e7d86317f2e4bb778d0278d5672f3a1ccde', '2026-10-16 13:54:29', 0, '2026-10-09 13:54:29'),
(749, 5, '4587783acc3c4b6fc1ae2da3c07bbafd5d6cb99305e0aeaaec5d9a822c0f53f0', '2026-10-16 13:54:46', 0, '2026-10-09 13:54:46'),
(750, 5, 'a3d90bf7127aa1ef88cee2c2a94b028fc5cb65de20653e30aee7aec8ec08faf9', '2026-10-09 14:01:06', 1, '2026-10-09 13:59:15'),
(751, 7, 'bebb93575ebae501081c1b567e21134f2893d238039823d54f9e5aed12e4a5c5', '2026-10-09 14:01:33', 1, '2026-10-09 14:01:33'),
(752, 7, 'a53ad7d7f85135018a495dda0ce2d9fcdc880a7e6cf6f7e3af3e8c8901fdcc6b', '2026-10-09 14:01:39', 1, '2026-10-09 14:01:33'),
(753, 7, '8e744ad98b323f572b986090326b55ac65fb1db19ecb300b22de61772e154979', '2026-10-09 14:01:43', 1, '2026-10-09 14:01:39'),
(754, 7, '746c3a44ae329584b94119da6c99142390e55f0fabe3856d8b805bd0631cb851', '2026-10-09 14:01:50', 1, '2026-10-09 14:01:43'),
(755, 7, 'f39c7a43cb555f61a4332453dde857874ab2ded743134dc25bdbb8db75b5d445', '2026-10-09 14:01:55', 1, '2026-10-09 14:01:50'),
(756, 7, 'd3ee2ec298de3118014eb4ec0089cf1df8a6c10747df3a9e2757972f8d1597c7', '2026-10-09 14:02:03', 1, '2026-10-09 14:01:55'),
(757, 7, '44821eb9490b7611575496e2f8746d7a34c995b480564a29b3ae354626a0a5c9', '2026-10-09 14:02:07', 1, '2026-10-09 14:02:03'),
(758, 7, '7fe2f189539c1a3de3a67d7f7bdb30e18aa618847079f327906af58be46a36ac', '2026-10-12 20:02:21', 1, '2026-10-09 14:02:07'),
(759, 8, '2ea803b221cdd289c3c16fc1efaf4e9bd1b7cdbe2462eafd7cb589e4cc202b3f', '2026-10-17 07:13:27', 0, '2026-10-10 07:13:27'),
(760, 7, 'a4f63007bc0929c49b545c3f2efc12a063c3e89e7dee2b62079f70d515ee6dc8', '2026-10-12 20:02:21', 1, '2026-10-12 20:02:21'),
(761, 7, '1f57669268f291643c2b1035504781c9286947d6830a9f1abbdff9f5d8248e01', '2026-10-12 20:02:35', 1, '2026-10-12 20:02:21'),
(762, 7, '118105b8250432b61f19c75c5bbf3cf81b6b64e6eb950d7f338571727756c9ed', '2026-10-12 20:02:37', 1, '2026-10-12 20:02:35'),
(763, 7, 'e2470cf7d163d676405ab27a3483e28e46b5a8a3ea0dc0bd2ed7346b960b670d', '2026-10-13 06:12:16', 1, '2026-10-12 20:02:37'),
(764, 9, '87468de1ac5e90bd2d9dd9d6526a8fcdb01558cfa46c0ef5f297630ed2e78bd9', '2026-10-19 20:39:43', 0, '2026-10-12 20:39:43'),
(765, 9, '1ca31bd5a7fa313f24e939b598de39b49f6083866adf883723a4a21e2c3ceacc', '2026-10-19 20:41:25', 0, '2026-10-12 20:41:25'),
(766, 7, 'cad4849db2a8560f495a47a50526223d6ddbea67fc9560ef37369bf2d43749f1', '2026-10-13 06:12:16', 1, '2026-10-13 06:12:16'),
(767, 7, '3987e82a97b5b7a0c19c5fcde9d5acb247fce777451c2216ba153de0535e389f', '2026-10-13 06:12:41', 1, '2026-10-13 06:12:16'),
(768, 7, '20bd346ece33965f1ce8c4f6b34a84ae6585fb97040475c022cd4268d215ec60', '2026-10-13 06:12:48', 1, '2026-10-13 06:12:41'),
(769, 7, '9a3b934deecb38fbeab49aa3196ac7bac58a537d4fa957991e80f403c3a78608', '2026-10-13 06:13:55', 1, '2026-10-13 06:12:48'),
(770, 7, '20c502ef6d72941660aa9b3a96895c8a12f2a00237943e50dc99c1027244b7e3', '2026-10-13 06:14:15', 1, '2026-10-13 06:13:55'),
(771, 7, 'b7c6c97f5705c4973b2c21b482fbf86efdd7350c335450a4849c4799280f4f1a', '2026-10-13 06:14:19', 1, '2026-10-13 06:14:15'),
(772, 7, 'ed1b01041809112ab38324e7e8e813777c8d7aa59a329d3ce1fd6e2b26363782', '2026-10-13 06:14:30', 1, '2026-10-13 06:14:19'),
(773, 7, '3fcb612435c0a726078b59453d4f63bb0899fcd3b8b0fd55d5372c0ec38f169c', '2026-10-13 06:14:43', 1, '2026-10-13 06:14:30'),
(774, 7, 'c0ffe81cfe1ad8d45b13b9190b27144bc036849adaea9729e213213479a9c986', '2026-10-13 06:14:45', 1, '2026-10-13 06:14:43'),
(775, 7, 'cf9650041ab33382baeeeb14bb3859fcba5a17d9f1dea487d225c68c6e5ab283', '2026-10-13 06:14:49', 1, '2026-10-13 06:14:45'),
(776, 7, 'cf0fafe6c5a6f43873e6458428e41161179bcef5a86340a04a7da36d155c795b', '2026-10-13 06:14:50', 1, '2026-10-13 06:14:49'),
(777, 7, 'a013756eccda702bed40591fa9150b6e5a8a70d8143544216966b9d0ed342c95', '2026-10-13 06:14:58', 1, '2026-10-13 06:14:50'),
(778, 7, '1a301d61d4dfd7416ab2bf89249975e8795ba336d8afe69b09c669b58fa28239', '2026-10-13 06:15:06', 1, '2026-10-13 06:14:58'),
(779, 6, '6ece2066712011f487063504da80cb3d588c7570ed1e1e931379d2c9a30e6fcd', '2026-10-13 11:39:53', 1, '2026-10-13 11:22:29'),
(780, 6, '6c81585c1db2ac8b51f68c47e0f5af77c44653c4499f12bfdfa825643ab12ce1', '2026-10-20 11:39:53', 0, '2026-10-13 11:39:53'),
(781, 6, '42b2e6af1b33e4419fe6443bbe894fc33e2ad2fab9e1cba282af8c03222cb6c9', '2026-10-20 12:04:03', 0, '2026-10-13 12:04:03'),
(782, 8, '1c1445c2d4f388ff75e48e00361a33c176953ba06a8dc568e196621dd24e8951', '2026-10-14 19:48:30', 1, '2026-10-14 19:33:30'),
(783, 8, '189bb782c8b5830d702447b82541fe6233057264c0851544e94db89348fdeaab', '2026-10-14 19:42:40', 1, '2026-10-14 19:42:39'),
(784, 8, 'fc7f0725e9a79286d60b7f8e647a5d20c76b4b9a11e36a58110bde85c94ab7dc', '2026-10-14 19:43:47', 1, '2026-10-14 19:42:40'),
(785, 8, '4d626d19dde05dd22fa7f06873cc226e4ceec21f8d26d93462a21a3ee3970620', '2026-10-14 19:44:22', 1, '2026-10-14 19:43:47'),
(786, 8, '566baf3795b0cc2272d3d334f10a9d069b44a7b6e052297401286819ab4eb118', '2026-10-14 19:44:30', 1, '2026-10-14 19:44:22'),
(787, 8, 'e6f3a2e4fd82f8481784809c0c485cb6866c66d99fd104c951b48feea2ff316e', '2026-10-14 19:44:55', 1, '2026-10-14 19:44:30'),
(788, 8, '502b950f6ce855e785687399c3b6fe594aba83db9b3d92230fa99155183512fd', '2026-10-14 19:45:24', 1, '2026-10-14 19:44:55'),
(789, 8, '53ebdbe7176790c6af57c77c20a36e36248b7096749192bd0a29d7470a4c0bbe', '2026-10-14 19:45:31', 1, '2026-10-14 19:45:25'),
(790, 8, '47322cfb9ea1ded1848e7ced5e2c8be7c90d4dc963b0d0a572075eee9976d61c', '2026-10-14 19:45:36', 1, '2026-10-14 19:45:31'),
(791, 8, '83bfeaaac0e534b1801d5bb7bf39c94989f2a5a8dd979230a6e74812cc2ab4f5', '2026-10-14 19:46:02', 1, '2026-10-14 19:45:37'),
(792, 8, 'b349a011b5d0272ec2e1530fc226048cf09782d87790378e9de613da0cc5a989', '2026-10-14 19:47:08', 1, '2026-10-14 19:46:02'),
(793, 8, '06c5c37eec5dc401e7f69802800cae1f666730ec8d91252636c7bdd2b42de9b6', '2026-10-14 19:47:12', 1, '2026-10-14 19:47:08'),
(794, 8, '1e6afce03e8b3be9ce2235555da0ba3dd2a2126a7419b94af318aedace32d118', '2026-10-14 19:47:20', 1, '2026-10-14 19:47:12'),
(795, 8, 'aae526efe60f9dd1a11e57760e413e2b81799f2334104b570b7e1222b7f1a919', '2026-10-14 19:48:17', 1, '2026-10-14 19:47:21'),
(796, 8, '54e05b16ffe3e9aaa53023be270ef6ed5a024dc8b82a024b5f4127e036a0222c', '2026-10-14 19:48:19', 1, '2026-10-14 19:48:17'),
(797, 8, '3d9f736051e4ffd30628320f63b5c447c2ee93b7251403ab39211d91cf2b843e', '2026-10-14 19:48:42', 1, '2026-10-14 19:48:20'),
(798, 8, '91deef97a7823045f69d213e89e3cbba3e97b28586e1a098ddabe50fad569cd7', '2026-10-14 19:50:00', 1, '2026-10-14 19:48:31'),
(799, 8, '1e3e4c493f1cc46d28a2d85a09616ffd4a61645dc83979a6a1159c2d9a39c095', '2026-10-14 19:48:52', 1, '2026-10-14 19:48:42'),
(800, 8, 'a968eb52fdbb7b5f55118f8fd177412461b71350c2fd0b77bed1b148d46d2827', '2026-10-14 19:49:12', 1, '2026-10-14 19:48:52'),
(801, 8, '4b2add566084285ac7988d6ccb3bcbc1f49752e25d803acf82bee64f83995ce0', '2026-10-14 19:52:22', 1, '2026-10-14 19:49:12'),
(802, 5, 'ea3891c68babe8faae140cce9ce9a243c96cd6b1fe4315e925dd6542470c6f6c', '2026-10-14 19:52:34', 1, '2026-10-14 19:52:33'),
(803, 5, '498751935d852cb73b935e5460f9925b7f2d81e46831a58f253edaf6ad8880ae', '2026-10-14 19:52:42', 1, '2026-10-14 19:52:34'),
(804, 5, '725264da72c5e102f70835fb9e3e5f6a6983ae0820d8182785f9780b420728d2', '2026-10-14 19:54:24', 1, '2026-10-14 19:52:42'),
(805, 5, '0a30ee89450ade894162d3dd88908b7b9e8c52c966b678cbfcdcadd9c267e668', '2026-10-14 20:29:13', 1, '2026-10-14 19:53:05'),
(806, 5, 'f714257fb57d0b7bc241f160079381ebf94d75bf9ee080f94eb01f14c4afdc83', '2026-10-14 19:55:16', 1, '2026-10-14 19:54:24'),
(807, 5, '287f47567fbf818c115cbacf044b0c626cdc76cb5c399825cf04212cb930e3f3', '2026-10-14 20:39:31', 1, '2026-10-14 19:55:16'),
(808, 5, 'eddeb91cfe657a377d74001111ecb6839cef350338135d7c6b249ed4928f80cf', '2026-10-21 20:29:13', 0, '2026-10-14 20:29:13'),
(809, 5, '90f3da79bbc9a8250636b1683848fdea6d300d7a5d54c6daab669278cc6e8256', '2026-10-14 20:39:38', 1, '2026-10-14 20:39:31'),
(810, 5, '72f5dd0fee45fa39056686140654da13b9ec9870e5cac22ba4537e7fac4d84a7', '2026-10-14 20:39:39', 1, '2026-10-14 20:39:38'),
(811, 5, '79e4672a4cb91cff46a637f03e6e5dff7d89de210ec3d3f985954b832c889bde', '2026-10-14 20:39:48', 1, '2026-10-14 20:39:40'),
(812, 5, '4d17a8ef09054698f37cf645b31a077e9f1663fccd550192794c2beac7b7d7c8', '2026-10-14 20:39:56', 1, '2026-10-14 20:39:48'),
(813, 5, '026a9cf313b65be4f614c77fd63b45dc12cb1f2e295ca0208b3717cbe9ff6110', '2026-10-14 20:40:01', 1, '2026-10-14 20:39:57'),
(814, 5, '4df8256620404e815292b3164a844cae785728ae66c1aaefb30686bb29381837', '2026-10-16 10:43:10', 1, '2026-10-14 20:40:01'),
(815, 8, '72317f011dac63d3cb7f0dbb150124fa51e6b993b402055d5a3e630091c8313b', '2026-10-15 10:51:55', 1, '2026-10-15 10:51:46'),
(816, 8, 'b1a46ad35cf55d7724853ef5c9ca38b25d773f91fd15c8a4d0b576996915937a', '2026-10-15 11:03:26', 1, '2026-10-15 11:03:11'),
(817, 8, '276f31c8b995cc95411c93958010db00a05b6cc5c6d6fafefd7e5cde55c4547a', '2026-10-15 11:06:49', 1, '2026-10-15 11:06:04'),
(818, 5, '1755e273f535bdb451d2cd8bec48471eb835dd5206f015ad98ccaf10ed68ecfc', '2026-10-16 10:43:11', 1, '2026-10-16 10:43:10'),
(819, 5, '0ee4d3a99b609d1c01e5ce211eb71f08c944ebdd9b5f6f96afe8796a5de4785a', '2026-10-16 10:43:19', 1, '2026-10-16 10:43:11'),
(820, 5, 'b7addb6703808ffe998f7f53563f141a14a175a4bb0c3122fb15bd655613fcf1', '2026-10-16 10:43:27', 1, '2026-10-16 10:43:26'),
(821, 5, 'a4de7653a59945d559e527b73c5fe227b6cf202a583d29bca0c28a95b7b2f66b', '2026-10-23 10:43:27', 0, '2026-10-16 10:43:27');

-- --------------------------------------------------------

--
-- Structure de la table `reinitialisations_mot_de_passe`
--

CREATE TABLE `reinitialisations_mot_de_passe` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` int(10) UNSIGNED NOT NULL,
  `email` varchar(190) NOT NULL,
  `code_hash` char(64) NOT NULL,
  `expire_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `tentatives` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `utilise` tinyint(1) NOT NULL DEFAULT 0,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reinitialisations_mot_de_passe`
--

INSERT INTO `reinitialisations_mot_de_passe` (`id`, `utilisateur_id`, `email`, `code_hash`, `expire_le`, `tentatives`, `utilise`, `cree_le`) VALUES
(1, 8, 'rakotomamonjyluciano1707@gmail.com', 'fe62e2c102f108e0d83e50a5ecd1954237db0a6b23b2175551e59a64b5fab004', '2026-09-24 14:31:05', 0, 1, '2026-09-24 14:21:25'),
(2, 8, 'rakotomamonjyluciano1707@gmail.com', 'e0300f4779f662ff193255dbd5473e48f450d582dbe7c93ea1031ec88c938c14', '2026-09-24 14:50:01', 0, 1, '2026-09-24 14:31:05'),
(3, 8, 'rakotomamonjyluciano1707@gmail.com', '0a9623b20498c981cd1decf68bb43af2c4c6b43290e5030e15d88d0e0fcf27ab', '2026-09-24 14:55:08', 0, 1, '2026-09-24 14:50:01'),
(4, 8, 'rakotomamonjyluciano1707@gmail.com', '6fa560154c3301c8e57ac9fce25a0fd4666d512bc205d23d553e1a479ea6a48f', '2026-09-28 11:42:31', 0, 1, '2026-09-24 14:55:08'),
(5, 8, 'rakotomamonjyluciano1707@gmail.com', '809bea02c8449daf36c8fbdf2801e02a005a30d02c624e5abf68f1851d878144', '2026-09-28 11:51:50', 0, 1, '2026-09-28 11:42:31'),
(6, 8, 'rakotomamonjyluciano1707@gmail.com', '4826ecca8c975f287b7f68f20e6a89e1fb2132444e70426b5132fd5e015eed51', '2026-09-28 11:53:22', 0, 1, '2026-09-28 11:51:50'),
(7, 8, 'rakotomamonjyluciano1707@gmail.com', 'b093c3890ce8360a4e447e2f4ed16587c06d6f6b59109e5be907ec98f5f97a4f', '2026-09-28 11:54:12', 0, 1, '2026-09-28 11:53:22'),
(8, 8, 'mickaramtovo@gmail.com', '87bd082dcaa6f206e7f7641424513c200834f899308f0ce3421606c453558664', '2026-09-28 12:14:19', 0, 0, '2026-09-28 11:59:19');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id` int(10) UNSIGNED NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) DEFAULT NULL,
  `email` varchar(190) NOT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `role` enum('directeur','chef_chantier','comptable','magasinier') NOT NULL DEFAULT 'chef_chantier',
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `doit_changer_mdp` tinyint(1) NOT NULL DEFAULT 0,
  `derniere_connexion` timestamp NULL DEFAULT NULL,
  `cree_le` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifie_le` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`id`, `nom`, `prenom`, `email`, `telephone`, `mot_de_passe`, `role`, `actif`, `doit_changer_mdp`, `derniere_connexion`, `cree_le`, `modifie_le`) VALUES
(5, 'Randriamanana', 'Tiana', 'directeur@digitalchantier.mg', NULL, '$2y$10$kLXttKyRsL5wzIIKdDOGDuP5mF/p0Ds/sIY32WRBSBTGgNgouEju6', 'directeur', 1, 0, '2026-10-16 10:43:26', '2026-07-08 02:50:43', '2026-10-16 10:43:26'),
(6, 'Rakotoarisoa', 'Hery', 'hery.chef@digitalchantier.mg', NULL, '$2y$10$kLXttKyRsL5wzIIKdDOGDuP5mF/p0Ds/sIY32WRBSBTGgNgouEju6', 'chef_chantier', 1, 0, '2026-10-13 12:04:03', '2026-07-08 06:01:38', '2026-10-13 12:04:03'),
(7, 'Randria', 'Naina', 'rakotomamonjyluciano1707@gmail.com', NULL, '$2y$10$kLXttKyRsL5wzIIKdDOGDuP5mF/p0Ds/sIY32WRBSBTGgNgouEju6', 'comptable', 1, 0, '2026-10-09 14:01:33', '2026-07-08 06:01:38', '2026-10-09 14:01:33'),
(8, 'Randrianja', 'Paul', 'mickaramtovo@gmail.com', '0377586014', '$2y$10$1to1swJ0C8uJUfR4JYHctOETGNg4dQK4mdjIynAnYz9sXJ7hkwx2O', 'magasinier', 1, 0, '2026-10-15 11:06:04', '2026-07-08 06:01:38', '2026-10-15 11:06:04'),
(9, 'QA Test', NULL, 'qa.test@example.com', NULL, '$2y$10$vClntI404oUb3wzIUURRfuL4TluWOGf88bTVj/Cks5IOC2mRy065a', 'directeur', 1, 0, '2026-10-12 20:41:25', '2026-10-12 20:24:48', '2026-10-12 20:41:25'),
(10, 'Chef', NULL, 'qa.chef@example.com', NULL, '$2y$10$diSAmOjgKA6wlAI.tI9UhOTPQMK1JEA7pm1AGEnxPq2HhuPm1Cj56', 'chef_chantier', 1, 0, NULL, '2026-10-12 20:41:35', '2026-10-12 20:41:35'),
(11, 'Compta', NULL, 'qa.compta@example.com', NULL, '$2y$10$eOeWvj2Jq0aFS7Gvmavwpu42DF1wE94zAAO9wnGKWmE1KeZ4KlWf6', 'comptable', 1, 0, NULL, '2026-10-12 20:41:35', '2026-10-12 20:41:35'),
(12, 'Magasin', NULL, 'qa.magasin@example.com', NULL, '$2y$10$UmAhd4mwTu1YzdAiUN8C3O684FAPKvrwyvBh0hz9auVsbHIqrOw76', 'magasinier', 1, 0, NULL, '2026-10-12 20:41:35', '2026-10-12 20:41:35');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `achats`
--
ALTER TABLE `achats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reference` (`reference`),
  ADD KEY `idx_achats_chantier` (`chantier_id`),
  ADD KEY `idx_achats_statut` (`statut`),
  ADD KEY `fk_achats_fournisseur` (`fournisseur_id`),
  ADD KEY `fk_achats_auteur` (`cree_par`);

--
-- Index pour la table `achat_lignes`
--
ALTER TABLE `achat_lignes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_lignes_achat` (`achat_id`),
  ADD KEY `fk_lignes_materiau` (`materiau_id`);

--
-- Index pour la table `chantiers`
--
ALTER TABLE `chantiers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_chantiers_statut` (`statut`),
  ADD KEY `idx_chantiers_nom` (`nom`),
  ADD KEY `fk_chantiers_client` (`client_id`),
  ADD KEY `fk_chantiers_responsable` (`responsable_id`);

--
-- Index pour la table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_clients_nom` (`nom`),
  ADD KEY `idx_clients_actif` (`actif`);

--
-- Index pour la table `devis`
--
ALTER TABLE `devis`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reference` (`reference`),
  ADD KEY `idx_devis_client` (`client_id`),
  ADD KEY `idx_devis_statut` (`statut`),
  ADD KEY `fk_devis_chantier` (`chantier_id`),
  ADD KEY `fk_devis_auteur` (`cree_par`);

--
-- Index pour la table `devis_lignes`
--
ALTER TABLE `devis_lignes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_devislignes_devis` (`devis_id`);

--
-- Index pour la table `employes`
--
ALTER TABLE `employes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `matricule` (`matricule`),
  ADD KEY `idx_employes_nom` (`nom`),
  ADD KEY `idx_employes_actif` (`actif`);

--
-- Index pour la table `engins`
--
ALTER TABLE `engins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_engins_designation` (`designation`),
  ADD KEY `idx_engins_etat` (`etat`);

--
-- Index pour la table `factures`
--
ALTER TABLE `factures`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reference` (`reference`),
  ADD KEY `idx_factures_client` (`client_id`),
  ADD KEY `idx_factures_statut` (`statut`),
  ADD KEY `fk_factures_devis` (`devis_id`),
  ADD KEY `fk_factures_chantier` (`chantier_id`),
  ADD KEY `fk_factures_auteur` (`cree_par`);

--
-- Index pour la table `facture_lignes`
--
ALTER TABLE `facture_lignes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_facturelignes_facture` (`facture_id`);

--
-- Index pour la table `fournisseurs`
--
ALTER TABLE `fournisseurs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fournisseurs_nom` (`nom`),
  ADD KEY `idx_fournisseurs_actif` (`actif`);

--
-- Index pour la table `journal_audit`
--
ALTER TABLE `journal_audit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_journal_utilisateur` (`utilisateur_id`),
  ADD KEY `idx_journal_entite` (`entite`,`entite_id`),
  ADD KEY `idx_journal_date` (`cree_le`);

--
-- Index pour la table `lots`
--
ALTER TABLE `lots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_lots_chantier` (`chantier_id`);

--
-- Index pour la table `materiaux`
--
ALTER TABLE `materiaux`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_materiaux_designation` (`designation`),
  ADD KEY `idx_materiaux_actif` (`actif`);

--
-- Index pour la table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fichier` (`fichier`);

--
-- Index pour la table `mouvements_stock`
--
ALTER TABLE `mouvements_stock`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_mouvements_materiau` (`materiau_id`),
  ADD KEY `idx_mouvements_chantier` (`chantier_id`),
  ADD KEY `fk_mouvements_achat` (`achat_id`),
  ADD KEY `fk_mouvements_auteur` (`cree_par`);

--
-- Index pour la table `paiements`
--
ALTER TABLE `paiements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_paiements_facture` (`facture_id`),
  ADD KEY `fk_paiements_auteur` (`cree_par`);

--
-- Index pour la table `parametres`
--
ALTER TABLE `parametres`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cle` (`cle`);

--
-- Index pour la table `pointages`
--
ALTER TABLE `pointages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pointage_employe_jour` (`employe_id`,`date_pointage`),
  ADD KEY `idx_pointages_chantier` (`chantier_id`,`date_pointage`),
  ADD KEY `fk_pointages_lot` (`lot_id`),
  ADD KEY `fk_pointages_auteur` (`cree_par`);

--
-- Index pour la table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_refresh_hash` (`token_hash`),
  ADD KEY `idx_refresh_utilisateur` (`utilisateur_id`);

--
-- Index pour la table `reinitialisations_mot_de_passe`
--
ALTER TABLE `reinitialisations_mot_de_passe`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_reset_email` (`email`,`utilise`,`expire_le`),
  ADD KEY `idx_reset_utilisateur` (`utilisateur_id`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_utilisateurs_role` (`role`),
  ADD KEY `idx_utilisateurs_actif` (`actif`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `achats`
--
ALTER TABLE `achats`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `achat_lignes`
--
ALTER TABLE `achat_lignes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `chantiers`
--
ALTER TABLE `chantiers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `devis`
--
ALTER TABLE `devis`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `devis_lignes`
--
ALTER TABLE `devis_lignes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `employes`
--
ALTER TABLE `employes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `engins`
--
ALTER TABLE `engins`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `factures`
--
ALTER TABLE `factures`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `facture_lignes`
--
ALTER TABLE `facture_lignes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `fournisseurs`
--
ALTER TABLE `fournisseurs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `journal_audit`
--
ALTER TABLE `journal_audit`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=848;

--
-- AUTO_INCREMENT pour la table `lots`
--
ALTER TABLE `lots`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `materiaux`
--
ALTER TABLE `materiaux`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `mouvements_stock`
--
ALTER TABLE `mouvements_stock`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT pour la table `paiements`
--
ALTER TABLE `paiements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `parametres`
--
ALTER TABLE `parametres`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `pointages`
--
ALTER TABLE `pointages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT pour la table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=822;

--
-- AUTO_INCREMENT pour la table `reinitialisations_mot_de_passe`
--
ALTER TABLE `reinitialisations_mot_de_passe`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `achats`
--
ALTER TABLE `achats`
  ADD CONSTRAINT `fk_achats_auteur` FOREIGN KEY (`cree_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_achats_chantier` FOREIGN KEY (`chantier_id`) REFERENCES `chantiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_achats_fournisseur` FOREIGN KEY (`fournisseur_id`) REFERENCES `fournisseurs` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `achat_lignes`
--
ALTER TABLE `achat_lignes`
  ADD CONSTRAINT `fk_lignes_achat` FOREIGN KEY (`achat_id`) REFERENCES `achats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_lignes_materiau` FOREIGN KEY (`materiau_id`) REFERENCES `materiaux` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `chantiers`
--
ALTER TABLE `chantiers`
  ADD CONSTRAINT `fk_chantiers_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_chantiers_responsable` FOREIGN KEY (`responsable_id`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `devis`
--
ALTER TABLE `devis`
  ADD CONSTRAINT `fk_devis_auteur` FOREIGN KEY (`cree_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_devis_chantier` FOREIGN KEY (`chantier_id`) REFERENCES `chantiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_devis_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `devis_lignes`
--
ALTER TABLE `devis_lignes`
  ADD CONSTRAINT `fk_devislignes_devis` FOREIGN KEY (`devis_id`) REFERENCES `devis` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `factures`
--
ALTER TABLE `factures`
  ADD CONSTRAINT `fk_factures_auteur` FOREIGN KEY (`cree_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_factures_chantier` FOREIGN KEY (`chantier_id`) REFERENCES `chantiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_factures_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_factures_devis` FOREIGN KEY (`devis_id`) REFERENCES `devis` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `facture_lignes`
--
ALTER TABLE `facture_lignes`
  ADD CONSTRAINT `fk_facturelignes_facture` FOREIGN KEY (`facture_id`) REFERENCES `factures` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `lots`
--
ALTER TABLE `lots`
  ADD CONSTRAINT `fk_lots_chantier` FOREIGN KEY (`chantier_id`) REFERENCES `chantiers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `mouvements_stock`
--
ALTER TABLE `mouvements_stock`
  ADD CONSTRAINT `fk_mouvements_achat` FOREIGN KEY (`achat_id`) REFERENCES `achats` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mouvements_auteur` FOREIGN KEY (`cree_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mouvements_chantier` FOREIGN KEY (`chantier_id`) REFERENCES `chantiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mouvements_materiau` FOREIGN KEY (`materiau_id`) REFERENCES `materiaux` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `paiements`
--
ALTER TABLE `paiements`
  ADD CONSTRAINT `fk_paiements_auteur` FOREIGN KEY (`cree_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_paiements_facture` FOREIGN KEY (`facture_id`) REFERENCES `factures` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `pointages`
--
ALTER TABLE `pointages`
  ADD CONSTRAINT `fk_pointages_auteur` FOREIGN KEY (`cree_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pointages_chantier` FOREIGN KEY (`chantier_id`) REFERENCES `chantiers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pointages_employe` FOREIGN KEY (`employe_id`) REFERENCES `employes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pointages_lot` FOREIGN KEY (`lot_id`) REFERENCES `lots` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_refresh_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `reinitialisations_mot_de_passe`
--
ALTER TABLE `reinitialisations_mot_de_passe`
  ADD CONSTRAINT `fk_reset_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
