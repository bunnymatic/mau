-- MySQL dump 10.11
--
-- Host: localhost    Database: mau_dev
-- ------------------------------------------------------
-- Server version	5.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `art_pieces`
--

DROP TABLE IF EXISTS `art_pieces`;
CREATE TABLE `art_pieces` (
  `id` int(11) NOT NULL auto_increment,
  `filename` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `style` varchar(255) default NULL,
  `dimensions` varchar(255) default NULL,
  `artist_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `medium_id` int(11) default NULL,
  `year` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `art_pieces`
--

LOCK TABLES `art_pieces` WRITE;
/*!40000 ALTER TABLE `art_pieces` DISABLE KEYS */;
INSERT INTO `art_pieces` VALUES (11,'/artistdata/1/imgs/1254293181splendid_cigar.jpg','super duper','',NULL,'',1,'2009-09-30 06:46:21','2009-10-25 21:43:33',10,2009),(12,'/artistdata/1/imgs/1254443609image.png','blue','',NULL,'',1,'2009-10-02 00:33:29','2009-10-26 16:10:19',12,NULL),(14,'/artistdata/1/imgs/12544436353532.jpg','Rocket Ship','',NULL,'',1,'2009-10-02 00:33:55','2009-10-29 02:18:14',8,2007),(15,'/artistdata/3/imgs/1254456606D3X_0081.jpg','test','yo',NULL,'',3,'2009-10-02 04:10:06','2009-10-02 04:10:07',6,NULL),(16,'/artistdata/3/imgs/1254457673D3X_0326.jpg','','',NULL,'',3,'2009-10-02 04:27:53','2009-10-02 04:27:54',6,NULL),(17,'/artistdata/3/imgs/1254457698D3X_0130.jpg','123213','123213',NULL,'',3,'2009-10-02 04:28:18','2009-10-02 04:28:19',6,NULL),(18,'/artistdata/3/imgs/1254457725D3X_0099.jpg','asd','asd',NULL,'',3,'2009-10-02 04:28:45','2009-10-02 04:28:46',6,NULL),(19,'/artistdata/3/imgs/1254457746D3X_0605.jpg','asd','sd',NULL,'',3,'2009-10-02 04:29:06','2009-10-02 04:29:07',6,NULL),(20,'/artistdata/3/imgs/1254457773D3X_0649.jpg','as','sa',NULL,'',3,'2009-10-02 04:29:33','2009-10-02 04:29:34',6,NULL),(21,'/artistdata/3/imgs/1254457799D3X_0791.jpg','wwerwe','adfads',NULL,'',3,'2009-10-02 04:29:59','2009-10-02 04:30:00',6,NULL),(22,'/artistdata/3/imgs/1254457890D3X_0717.jpg','asdf','asdf',NULL,'',3,'2009-10-02 04:31:30','2009-10-02 04:31:31',6,NULL),(23,'/artistdata/3/imgs/1254457950D3X_0681.jpg','sdzf','asdf',NULL,'',3,'2009-10-02 04:32:30','2009-10-02 04:32:31',6,NULL),(24,'/artistdata/3/imgs/1254458014D3X_0844a.jpg','asd','asd',NULL,'',3,'2009-10-02 04:33:34','2009-10-02 04:33:35',6,NULL),(25,'/artistdata/1/imgs/1254950019Photo22.jpg','super',NULL,NULL,'',1,'2009-10-07 21:13:39','2009-10-26 18:09:03',9,NULL),(26,'/artistdata/4/imgs/1255848594motorhead_march_or_die.jog.jpg','testing upload',NULL,NULL,'really big',4,'2009-10-18 06:49:54','2009-10-18 06:49:55',6,2009),(28,'/artistdata/4/imgs/1255850145motorhead_march_or_die.jog.jpg','',NULL,NULL,'',4,'2009-10-18 07:15:45','2009-10-18 07:15:46',6,NULL),(33,'artistdata/4/imgs/1255850938life_is_pain.gif','new piece',NULL,NULL,'really big',4,'2009-10-18 07:28:58','2009-10-18 07:28:59',6,2008),(34,'artistdata/5/imgs/1256146158D3X_0028.jpg','one image',NULL,NULL,'big',5,'2009-10-21 17:29:18','2009-10-21 17:29:19',6,NULL),(35,'artistdata/6/imgs/1256573365bishopsky3.jpg','sky',NULL,NULL,'big',6,'2009-10-26 16:09:25','2009-10-26 16:09:26',10,2009),(36,'artistdata/6/imgs/1256590727sophia.jpg','ladies',NULL,NULL,'24x33',6,'2009-10-26 20:58:47','2009-10-26 20:58:47',15,2004),(37,'artistdata/6/imgs/1256590880ladies.jpg','Beach',NULL,NULL,'',6,'2009-10-26 21:01:20','2009-10-26 21:01:20',8,2002),(38,'artistdata/8/imgs/1256782964TheMeeting.jpg','Meeting',NULL,NULL,'24\" X 24\"',8,'2009-10-29 02:22:44','2009-10-29 02:22:45',7,2008),(39,'artistdata/8/imgs/1256783037moons.jpg','Moons',NULL,NULL,'',8,'2009-10-29 02:23:57','2009-10-29 02:23:57',0,NULL),(41,'artistdata/8/imgs/1256783176Waterscape.jpg','Waterscape',NULL,NULL,'28\" X 28\"',8,'2009-10-29 02:26:16','2009-10-29 02:26:17',0,2009),(42,'artistdata/9/imgs/1256789255one.eye.sm.jpg',' One-Eye',NULL,NULL,'5\" x 5\"',9,'2009-10-29 04:07:35','2009-10-29 04:07:36',0,2009),(43,'artistdata/9/imgs/1256790862KOI.SM.jpg','Koi and Lily',NULL,NULL,'11\" x 14\" ',9,'2009-10-29 04:34:22','2009-10-29 04:34:23',19,2009),(44,'artistdata/9/imgs/1256791135modcock2.jpg','Mod Cock',NULL,NULL,'12\' x 12\"',9,'2009-10-29 04:38:55','2009-10-29 04:38:57',19,2009),(45,'artistdata/9/imgs/1256791392ScreamerSM.jpg','Screamer',NULL,NULL,'6\" x 6\" ',9,'2009-10-29 04:43:12','2009-10-29 04:43:13',0,2008),(46,'artistdata/9/imgs/1256791811peekcheek.jpg','Peek',NULL,NULL,'6\" x 6\" ',9,'2009-10-29 04:50:11','2009-10-29 04:50:12',19,2009),(47,'artistdata/9/imgs/1256792115IMG_2173.jpg','Greta Garbo',NULL,NULL,'6\" x 6\"',9,'2009-10-29 04:55:15','2009-10-29 04:55:16',19,2009),(48,'artistdata/9/imgs/1256792392IMG_2180.jpg','comb over',NULL,NULL,'5\" x 5\"',9,'2009-10-29 04:59:52','2009-10-29 04:59:53',19,2008),(49,'artistdata/10/imgs/1256937305abaca_blue1_web.jpg','Love Letters - blue series',NULL,NULL,'',10,'2009-10-30 21:15:05','2009-10-30 21:15:05',10,2009),(50,'artistdata/1/imgs/1256939322D3X_0289.jpg','who doesn\'t love bunnys?',NULL,NULL,'bmatic',1,'2009-10-30 21:48:42','2009-11-03 00:18:05',9,0),(51,'artistdata/7/imgs/1256959848Anna_2009.JPG','Anna',NULL,NULL,'36 x 36',7,'2009-10-31 03:30:48','2009-10-31 03:30:50',11,2009),(52,'artistdata/7/imgs/1256959899TheAthelete.JPG','Athlete',NULL,NULL,'24 x 32',7,'2009-10-31 03:31:39','2009-10-31 03:31:41',11,2009),(53,'artistdata/7/imgs/1256960060soup.jpg','Soup',NULL,NULL,'40 x 40',7,'2009-10-31 03:34:20','2009-10-31 03:34:23',11,2009),(54,'artistdata/7/imgs/1256960109DSC_00140014.JPG','Heidi Waterman',NULL,NULL,'36 x 48',7,'2009-10-31 03:35:09','2009-10-31 03:35:11',11,2009),(55,'artistdata/7/imgs/1256960250DSC_00120012.JPG','Leo Fusco',NULL,NULL,'24 x 34',7,'2009-10-31 03:37:30','2009-10-31 03:37:32',11,2009),(56,'artistdata/7/imgs/1256960540DSC_00100010.JPG','Embrace',NULL,NULL,'30 x 40',7,'2009-10-31 03:42:20','2009-10-31 03:42:23',11,2009),(57,'artistdata/7/imgs/1256960956Copyoffable.jpg','Fable',NULL,NULL,'36 x 52',7,'2009-10-31 03:49:16','2009-10-31 03:49:17',11,2009),(58,'artistdata/11/imgs/1257134417Largerand..jpg','Larger And...',NULL,NULL,'60\" x 72\"',11,'2009-11-02 04:00:17','2009-11-02 04:00:21',12,2008),(59,'artistdata/11/imgs/1257134530Cathedral.jpg','Cathedral',NULL,NULL,'24\" x 36\"',11,'2009-11-02 04:02:10','2009-11-02 04:02:14',11,2009),(60,'artistdata/11/imgs/1257135174Bolt.jpg','Bolt',NULL,NULL,'36\" x 48\"',11,'2009-11-02 04:12:54','2009-11-02 04:12:58',11,2009),(61,'artistdata/11/imgs/1257135711AnotherFireInside.jpg','Another Fire Inside',NULL,NULL,'36\" x 36\"',11,'2009-11-02 04:21:51','2009-11-02 04:21:55',11,2009),(62,'artistdata/11/imgs/1257135830CarmelHighlands2_2.jpg','Lofty',NULL,NULL,'48\" x 72\"',11,'2009-11-02 04:23:50','2009-11-02 04:23:54',11,2007),(63,'artistdata/11/imgs/1257135991DragonAbstract1.1.jpg','Dragon Abstract 1',NULL,NULL,'36\" x 36\"',11,'2009-11-02 04:26:31','2009-11-02 04:26:35',12,2008),(64,'artistdata/11/imgs/1257136215KlineBranch.jpg','Kline Branch',NULL,NULL,'36\" x 24\"',11,'2009-11-02 04:30:15','2009-11-02 04:30:19',11,2009),(65,'artistdata/11/imgs/1257136516Sway.jpg','Sway',NULL,NULL,'40\" x 60\"',11,'2009-11-02 04:35:16','2009-11-02 04:35:19',11,2009),(66,'artistdata/11/imgs/1257136743TouchingTheBay1.jpg','Touching the Bay',NULL,NULL,'51\" x 90\"',11,'2009-11-02 04:39:03','2009-11-02 04:39:09',12,2008),(67,'artistdata/11/imgs/1257136910_Pacific.jpg','Pacific',NULL,NULL,'24\" x 24\"',11,'2009-11-02 04:41:50','2009-11-02 04:41:51',12,2005),(68,'artistdata/12/imgs/1257140128freedom.jpg','some piece',NULL,NULL,'12x12',12,'2009-11-02 05:35:28','2009-11-02 05:35:29',8,1900),(69,'artistdata/12/imgs/1257141732D3X_0988.jpg','the other one',NULL,NULL,'12x20',12,'2009-11-02 06:02:12','2009-11-02 06:02:13',8,1990);
/*!40000 ALTER TABLE `art_pieces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `art_pieces_tags`
--

DROP TABLE IF EXISTS `art_pieces_tags`;
CREATE TABLE `art_pieces_tags` (
  `tag_id` int(11) default NULL,
  `art_piece_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `art_pieces_tags`
--

LOCK TABLES `art_pieces_tags` WRITE;
/*!40000 ALTER TABLE `art_pieces_tags` DISABLE KEYS */;
INSERT INTO `art_pieces_tags` VALUES (3,26),(4,26),(5,26),(3,32),(4,32),(5,32),(6,32),(3,33),(4,33),(5,33),(6,33),(7,34),(8,34),(9,34),(10,35),(11,35),(12,35),(13,35),(14,35),(15,35),(10,12),(11,12),(16,12),(17,25),(18,25),(19,25),(20,36),(21,36),(22,36),(23,37),(24,37),(16,37),(2,12),(25,11),(26,11),(27,11),(28,11),(10,11),(29,14),(30,38),(31,38),(32,42),(33,42),(34,42),(13,42),(35,42),(36,43),(37,43),(38,43),(34,43),(13,43),(35,43),(33,44),(39,44),(40,44),(35,44),(34,44),(34,45),(35,45),(41,45),(33,45),(34,46),(35,46),(41,46),(33,46),(34,47),(35,47),(41,47),(33,47),(42,58),(43,58),(30,58),(45,58),(42,59),(43,59),(30,59),(45,59),(46,58),(47,58),(42,60),(43,60),(46,60),(47,60),(30,60),(45,60),(46,59),(47,59),(42,61),(43,61),(46,61),(47,61),(30,61),(45,61),(42,62),(43,62),(46,62),(47,62),(30,62),(45,62),(42,63),(43,63),(48,63),(49,63),(47,63),(30,63),(45,63),(42,64),(43,64),(7,64),(47,64),(30,64),(45,64),(42,65),(43,65),(46,65),(47,65),(30,65),(45,65),(42,66),(43,66),(7,66),(47,66),(30,66),(45,66),(42,67),(43,67),(7,67),(47,67),(30,67),(45,67),(50,68),(7,68),(51,68),(52,69),(53,69),(54,50),(55,50);
/*!40000 ALTER TABLE `art_pieces_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artist_images`
--

DROP TABLE IF EXISTS `artist_images`;
CREATE TABLE `artist_images` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `artist_images`
--

LOCK TABLES `artist_images` WRITE;
/*!40000 ALTER TABLE `artist_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `artist_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artist_profile_images`
--

DROP TABLE IF EXISTS `artist_profile_images`;
CREATE TABLE `artist_profile_images` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `artist_profile_images`
--

LOCK TABLES `artist_profile_images` WRITE;
/*!40000 ALTER TABLE `artist_profile_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `artist_profile_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artists`
--

DROP TABLE IF EXISTS `artists`;
CREATE TABLE `artists` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(40) default NULL,
  `name` varchar(100) default '',
  `email` varchar(100) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(40) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `firstname` varchar(40) default NULL,
  `lastname` varchar(40) default NULL,
  `nomdeplume` varchar(80) default NULL,
  `phone` varchar(16) default NULL,
  `url` varchar(200) default NULL,
  `profile_image` varchar(200) default NULL,
  `street` varchar(200) default NULL,
  `city` varchar(200) default NULL,
  `addr_state` varchar(4) default NULL,
  `zip` int(11) default NULL,
  `bio` text,
  `news` text,
  `role_id` int(11) default NULL,
  `studio_id` int(11) default NULL,
  `active` tinyint(1) default '1',
  `facebook` varchar(200) default NULL,
  `twitter` varchar(200) default NULL,
  `blog` varchar(200) default NULL,
  `myspace` varchar(200) default NULL,
  `flickr` varchar(200) default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `state` varchar(255) default 'passive',
  `deleted_at` datetime default NULL,
  `reset_code` varchar(40) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_artists_on_login` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `artists`
--

LOCK TABLES `artists` WRITE;
/*!40000 ALTER TABLE `artists` DISABLE KEYS */;
INSERT INTO `artists` VALUES (1,'bmatic','','bmatic@bmatic.com','6abc8b4f6cfedbc9bd37116ba3e9e753e7cb8ed5','c661e2d4dcb601da05c7be454c18a2bf939ea845','2009-08-02 00:45:07','2009-11-02 05:05:23',NULL,NULL,'mr','rogers',NULL,'','bunnymatic.com','artistdata/1/profile/profile.jpg','','San Francisco','CA',94110,'',NULL,NULL,0,1,'www.facebook.com','','','','',NULL,NULL,'active',NULL,NULL),(2,'trish','','trish@trishtunney.com','8dd2027a286857fdfffd73e83ea4a82ca6d5bb02','a7dc930a1093d557ee0b31e846a665e2c99176a0','2009-09-29 18:42:09','2009-09-29 18:42:45',NULL,NULL,'trish','yo',NULL,'415-609-1901','www.trishtunney.com',NULL,'','','',NULL,'i want to say something important about me here',NULL,NULL,2,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active',NULL,NULL),(3,'test123','','test@gmail.com','76c920c74f58f9c1c3ff04734bdcc7ff7a8dae0a','123c59932c0b5f2c352282ad07b17d2de58df7c5','2009-10-02 03:40:49','2009-10-02 03:40:49',NULL,NULL,'te','st',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active',NULL,NULL),(4,'bmatic2','','bmatic2@bunnymatic.com','a19e2c07ec6b680921a97bec23c5dcc947d0b85c','aef7fb201251f4bfbc68993c54ee69b8a64b023b','2009-10-18 06:48:45','2009-10-18 07:30:00',NULL,NULL,'bunny','matic',NULL,NULL,'http://www.obeymiffy.com','/artistdata/4/profile/profile.gif','234 wherever','some place','ca ',95410,'TEN COMMON MISTAKES ARTS GROUPS MAKE WHEN SEEKING GRANTS (from somebody who spent years seeking grants before joining a foundation and gradually learning how much he’d been doing wrong)\r\nPaulBotts_Headshot.jpg\r\n\r\n1) Basing your specific pitch to a foundation or corporate funder on anything other than what that funder says they want to fund.\r\n\r\nDon’t try to “read between the lines” or whatever. Because in the first place much of what artists and art groups think they know about arts funders is outdated, over-generalized or simply dead wrong. And in the second place, foundations and corporate arts funders nowadays try quite hard to be clear and transparent with grantseekers. So read the funder’s website thoroughly first and take what they say at face value. If you still have questions then do call them and ask: they’ll be glad to talk about it, because nothing gives a funder more heartburn than receiving written proposals that they have to turn down as not even close.\r\n\r\n2) Thinking that “the way to get grants is to start an outreach program.”\r\n\r\nThis is by far the most-pervasive urban legend about arts funding. At one time it was at least half true, but for some years now it’s been more of a trap.\r\n\r\nGeneral arts funders are now actually leery of arts groups creating new outreach or education programs to “chase the funding.” Lots of hard experience has taught those foundations that this is a big warning sign of organizational sloppiness, lack of focus, or desperation. Remember that arts funders are themselves non-profits carrying out a mission, and that mission is never served by having wasted grant money on an arts organization that turns out to be too poorly-led to get much of anything done.\r\n\r\nSo if you approach a foundation which lists arts and culture as something it funds and start talking about the snazzy new outreach program you started doing just last year, you might as well be wearing a big bright warning sign: “WILL SAY ANYTHING TO GET A CHECK.”',NULL,NULL,2,1,'http://www.facebook.com/home.php?#/pages/bunnymatic/43469254827','javascript:alert(\"hey this is a bug\");','','sucks','',NULL,NULL,'active',NULL,NULL),(5,'testy1','','testy1@testy.com','3185beab6175120060c75d6939053b30ba755dc0','5c64b67f0192848e604256a3fbf784db4f479651','2009-10-21 17:22:48','2009-10-21 17:24:51',NULL,NULL,'testy','testicle',NULL,'','www.testytest.com','artistdata/5/profile/profile.jpg','1890 bryant street','San Francisco','CA',94110,'This weekend, there will be nearly 150 artists opening their studios from Ocean Beach in the west; running up San Francisco on the north side; all the way to Fort Mason.   And, once again, everyone is asking “So Mike, where are you going?”    Well, I outlined my traditional strategy l',NULL,NULL,3,1,'www.facebook.com/testy1','www.tritter.com/testy1','www.blogger.co/testy1','www.myspace.com/testy1','www.flikr.com/testy1',NULL,NULL,'active',NULL,NULL),(6,'thedude','','thedude@bunnymatic.com','071417d1385834b3a290b9d0c611c67fc78cbd2f','68bc078d48415921be101c159f5467bb4003ef25','2009-10-26 16:08:32','2009-10-31 19:37:58',NULL,NULL,'Phillip','Glassy',NULL,'','','artistdata/6/profile/profile.jpg','','San Francisco','CA',94110,'',NULL,NULL,3,1,'','','','','',NULL,NULL,'active',NULL,NULL),(7,'paulmorin422','','paul@studiomorin.com','83b6aa24ae5d98ad6d0e7e992529ba037a089c30','ff4b14550198e353dc1539726a9d047bc29106ae','2009-10-29 01:14:34','2009-11-02 02:53:36','971242cc628ff55eafeebfa0f8d190ba4369904e','2009-11-14 03:29:49','Paul','Morin',NULL,'415-418-4267','www.studiomorin.com','artistdata/7/profile/profile.jpg','','San Francisco','CA',94110,'Paul Morin’s works are included in private collections on five continents and is a commissioned portrait painter.\r\n\r\nPaul grew up near Boston and was educated at Providence College and Mass College of Art.  After spending some time in the corporate world, he has fully embraced his career path in the visual arts.  His works have been shown in New York, Boston and San Francisco.\r\n\r\nPaul uses a painting technique derived from the 17th century masters.  Though rooted in a solid traditional technique, his works are decidedly modern with images that confront the viewer and a sense of scale that is very individual.  Though having engaged in the formal study of art, Paul feels that his technique is a culmination of many years of self-study and observation.  \r\n\r\nIn addition to being a fine artist, Paul is an accomplished singer and has sung with the Tanglewood Festival Chorus, The San Francisco Symphony Chorus and the Juilliard Choral Union.  \r\n\r\nAn accomplished portrait painter, Paul is available for commissions.\r\n',NULL,NULL,4,1,'','','','','',NULL,NULL,'active',NULL,NULL),(8,'robert','','robreedart@gmail.com','7be3ed5edf55f4382994ef246afbf3f700e1c71f','6d009b40b2e9fdcfad8a3d4f03116c1aaef64216','2009-10-29 01:53:21','2009-10-29 02:00:04',NULL,NULL,'Robert','Reed',NULL,'','www.robertreed.info','artistdata/8/profile/profile.jpg','2150 Folsom','San Francisco','CA',94110,'',NULL,NULL,3,1,'http://www.facebook.com/robertreed.art','http://twitter.com/RobReedArt','','','',NULL,NULL,'active',NULL,NULL),(9,'dkhaas','','dkhaas@gmail.com','952cb4cc10cd4aafa350e11fb082d4285f50db2a','8e9cdb3d06d0cd26f85daf477d5a181dfdcc9bf7','2009-10-29 03:30:30','2009-10-29 04:44:54',NULL,NULL,'dk','haas',NULL,'415 695-1901','dkhaas.com','artistdata/9/profile/profile.jpg','1084 Capp Street','San Francisco','CA',94110,'I am brilliant, creative, talented, prolific, oh and I like painting stuff. But I would also like to do image transfers cuz they look swell embedded in wax oh and I am a looking forward to a new series and a new time change and a wet and dark winter in California, maybe I\'ll be in Nevada in December where it is likely to be cold and dry...that\'s it for now kids. ',NULL,NULL,0,1,'dk haas','','apaintingaday@blogspot.com','','',NULL,NULL,'active',NULL,NULL),(10,'rhiannon.alpers','','rhiannon.alpers@mac.com','002359dea77071c65a5e5230d0c7c943de42fe52','8b361a6b2870da52fb4d96795c03b777f33e5544','2009-10-30 21:08:40','2009-10-30 21:16:20',NULL,NULL,'Rhiannon','Alpers',NULL,'','www.rhiannonalpers.com',NULL,'studio #311','San Francisco','CA',94110,'Rhiannon is a papermaker, letterpress printer and book artist. \r\n\r\nA transplant to the bay area, Rhiannon has an MFA in Book and Paper Arts from Columbia College Chicago and a BA in Book Arts from UC Santa Barbara. \r\nShe has taught workshops and college courses at San Francisco Center for the Book, Kala Printmaking Institute, Academy of Art University of San Francisco, Center for Book and Paper in Chicago, Columbia College Chicago, Paper Source stores in Chicago and San Francisco, and Santa Reparata School of Art in Florence, Italy. \r\n',NULL,NULL,4,1,'','','','','',NULL,NULL,'active',NULL,NULL),(11,'sevilla','','sevilla.granger@gmail.com','272b79a7cdfa73bd2cd04de370efbb75a5a95f21','4c5b76727e93fc36721e89d601c55a1076039f80','2009-11-02 03:32:06','2009-11-02 05:08:57',NULL,NULL,'Sevilla','Granger',NULL,'','http://www.villasevilla.com','artistdata/11/profile/profile.jpg','','San Francisco','CA',94110,'Born and trained in Asheville, North Carolina, Sevilla has been painting the natural world for most of her life.  With a grandmother who painted landscapes, a photographer for a Father and the daughter of Sallie Middleton as her best friend, art was omnipresent and encouraged in her formative years.\r\n\r\nIn the summer of 2003, after 15 years as a Costume Designer in the film industry, Sevilla was inspired to return to painting after an intense creative awakening on Palatine Hill in Rome. The work she makes today isn’t far from the original inspiration there, just being constantly refined and focused.\r\n\r\nSevilla currently lives in San Francisco, and works in the vibrant artistic community at the 1890 Bryant St. Studios.\r\n',NULL,NULL,4,1,'http://www.facebook.com/sevilla.granger','http://twitter.com/SevillaGranger','http://www.villasevilla.com/villasevilla.com/Blog/Blog.html','','',NULL,NULL,'active',NULL,NULL),(12,'trishtunney1','','trish@trishtunney.net','5032fdc5ae51f38b1edcd1ddbde46dfaa3d8f473','88a1263e0c3c89f71c724d7b6f6b9edaf013c1d1','2009-11-02 05:31:41','2009-11-02 05:40:56',NULL,NULL,'tricia','tunney',NULL,'','','artistdata/12/profile/profile.jpg','3128 21st Street','San Francisco','CA',94110,' back button on show artpiece goes back to edit if you just edited\r\n\r\n where should it go?  back to art page?\r\n\r\n we want it to use referrer because we want people who came from \"search\"\r\n page to go back to that search page.\r\n\r\n Trish, think about this one and let me know.\r\n we could probably do \"back to referrer unless it was edit page, then back\r\n to artists profile page\".  could be over complicated but i think that\'s\r\n the right behavior.\r\n\r\n what say you?',NULL,NULL,0,1,'','','','','',NULL,NULL,'active',NULL,NULL),(13,'dumbguy','','dumbguy@bunnymatic.com','37981236c17c8c6e258f7cf04f648018e30a3d36','6a0b8034396288eb366e61db4d967c521c80c594','2009-11-05 10:13:58','2009-11-05 10:22:39',NULL,NULL,'dumb','guy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'2009-11-05 10:22:39','active',NULL,NULL);
/*!40000 ALTER TABLE `artists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artists_events`
--

DROP TABLE IF EXISTS `artists_events`;
CREATE TABLE `artists_events` (
  `event_id` int(11) default NULL,
  `artist_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `artists_events`
--

LOCK TABLES `artists_events` WRITE;
/*!40000 ALTER TABLE `artists_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `artists_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artists_roles`
--

DROP TABLE IF EXISTS `artists_roles`;
CREATE TABLE `artists_roles` (
  `artist_id` int(11) default NULL,
  `role_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `artists_roles`
--

LOCK TABLES `artists_roles` WRITE;
/*!40000 ALTER TABLE `artists_roles` DISABLE KEYS */;
INSERT INTO `artists_roles` VALUES (1,1);
/*!40000 ALTER TABLE `artists_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `startdate` datetime default NULL,
  `enddate` datetime default NULL,
  `description` text,
  `url` varchar(255) default NULL,
  `image` varchar(255) default NULL,
  `street` varchar(255) default NULL,
  `city` varchar(255) default NULL,
  `state` varchar(255) default NULL,
  `zip` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (1,'first event','2009-08-13 04:02:00','2009-08-13 12:02:00','rock this event\r\n\r\nwith a link\r\nhttp://bunnymatic.com\r\n\r\nand some <b> bold html </b>\r\nand a <script>alert(\'script\');</script>','http://bunnymatic.com','whatever.jpg','here','and there','',9,'2009-08-13 04:03:41','2009-08-13 04:03:41');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `media`
--

LOCK TABLES `media` WRITE;
/*!40000 ALTER TABLE `media` DISABLE KEYS */;
INSERT INTO `media` VALUES (6,'Drawing','2009-10-20 15:48:37','2009-10-20 15:48:37'),(7,'Mixed-Media','2009-10-20 15:48:37','2009-10-20 15:48:37'),(8,'Photography','2009-10-20 15:48:37','2009-10-20 15:48:37'),(9,'Glass/Ceramics','2009-10-20 15:48:37','2009-10-20 15:48:37'),(10,'Printmaking','2009-10-20 15:48:37','2009-10-20 15:48:37'),(11,'Painting - Oil','2009-10-20 15:48:37','2009-10-20 15:48:37'),(12,'Painting - Acrylic','2009-10-20 15:48:37','2009-10-20 15:48:37'),(13,'Painting - Watercolor','2009-10-20 15:48:37','2009-10-20 15:48:37'),(14,'Sculpture','2009-10-20 15:48:37','2009-10-20 15:48:37'),(15,'Jewelry','2009-10-20 15:48:37','2009-10-20 15:48:37'),(16,'Fiber/Textile','2009-10-20 15:48:37','2009-10-20 15:48:37'),(17,'Furniture','2009-10-20 15:48:37','2009-10-20 15:48:37'),(18,'Bookmaking','2009-10-20 15:48:37','2009-10-30 22:45:12'),(19,'Painting - Encaustic','2009-10-29 04:32:12','2009-10-29 04:32:12');
/*!40000 ALTER TABLE `media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `role` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin','2009-10-20 15:52:51','2009-10-20 15:52:51');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles_artists`
--

DROP TABLE IF EXISTS `roles_artists`;
CREATE TABLE `roles_artists` (
  `role_id` int(11) default NULL,
  `artist_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `roles_artists`
--

LOCK TABLES `roles_artists` WRITE;
/*!40000 ALTER TABLE `roles_artists` DISABLE KEYS */;
/*!40000 ALTER TABLE `roles_artists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('200903000001'),('200903000002'),('20090712060553'),('20090712060605'),('20090714073807'),('20090714073815'),('20090714084247'),('20090802004224'),('20090802004228'),('20090802020807'),('20090802020820'),('20090802023451'),('20090803000002'),('20090813042401'),('20090813042508'),('20090813043116'),('20090813043120'),('20090813162855'),('20090813170645'),('20090813171520'),('20090813182152'),('20090913001003'),('20090913001213'),('20090916065455'),('20090929074818'),('20090929074918'),('20091004004507'),('20091004034218'),('20091004045540'),('20091020153318'),('20091020153324'),('20091020154958'),('20091029072600'),('20091101003536'),('20091104181444'),('20091105080318'),('20091105083138'),('200930000000');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `studios`
--

DROP TABLE IF EXISTS `studios`;
CREATE TABLE `studios` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `street` varchar(255) default NULL,
  `city` varchar(255) default NULL,
  `state` varchar(255) default NULL,
  `zip` int(11) default NULL,
  `url` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `profile_image` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `studios`
--

LOCK TABLES `studios` WRITE;
/*!40000 ALTER TABLE `studios` DISABLE KEYS */;
INSERT INTO `studios` VALUES (3,'Workspace Limited','2150 Folsom St','San Francisco','CA',94110,'http://www.workspacelimited.org','2009-09-29 08:48:20','2009-11-02 00:04:25','studiodata/3/profile/profile.jpg'),(4,'1890 Bryant Street Studios','1890 Bryant St','San Francisco','CA',94117,'http://www.1890bryant.com','2009-10-20 15:48:37','2009-11-01 23:54:48','studiodata/4/profile/profile.jpg'),(5,'ActivSpace','3150 18th Street, #102','San Francisco','CA',94117,'http://activspace.com','2009-10-20 15:48:37','2009-11-03 00:14:27','studiodata/5/profile/profile.jpg'),(6,'The Blue Studio','2111 Mission St','San Francisco','CA',94117,'http://thebluestudio.org','2009-10-20 15:48:37','2009-11-01 23:55:16','studiodata/6/profile/profile.jpg'),(7,'Developing Environments','540 Alabama St','San Francisco','CA',94117,'http://www.lightdark.com/deweb/index.html','2009-10-20 15:48:37','2009-10-20 15:48:37',NULL),(8,'Project Artaud','499 Alabama Street','San Francisco','CA',94117,'http://artaud.org','2009-10-20 15:48:37','2009-11-02 00:02:55','studiodata/8/profile/profile.jpg');
/*!40000 ALTER TABLE `studios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (1,'testtag','2009-08-02 00:44:25','2009-08-02 00:44:25'),(2,'super','2009-08-02 00:44:33','2009-08-02 00:44:33'),(3,'this','2009-10-18 06:49:54','2009-10-18 06:49:54'),(4,'that','2009-10-18 06:49:54','2009-10-18 06:49:54'),(5,'and the other','2009-10-18 06:49:54','2009-10-18 06:49:54'),(6,'and more','2009-10-18 07:22:43','2009-10-18 07:22:43'),(7,'blue','2009-10-21 17:29:18','2009-10-21 17:29:18'),(8,'hay','2009-10-21 17:29:18','2009-10-21 17:29:18'),(9,'hey','2009-10-21 17:29:18','2009-10-21 17:29:18'),(10,'funk','2009-10-26 16:09:25','2009-10-26 16:09:25'),(11,'soul','2009-10-26 16:09:25','2009-10-26 16:09:25'),(12,'sky','2009-10-26 16:09:25','2009-10-26 16:09:25'),(13,'painting','2009-10-26 16:09:25','2009-10-26 16:09:25'),(14,'graffiti','2009-10-26 16:09:25','2009-10-26 16:09:25'),(15,'cool','2009-10-26 16:09:25','2009-10-26 16:09:25'),(16,'hot','2009-10-26 16:10:38','2009-10-26 16:10:38'),(17,'self portrait','2009-10-26 18:09:03','2009-10-26 18:09:03'),(18,'portrait','2009-10-26 18:09:03','2009-10-26 18:09:03'),(19,'super duper','2009-10-26 18:09:03','2009-10-26 18:09:03'),(20,'ladies','2009-10-26 20:58:47','2009-10-26 20:58:47'),(21,'jewelery','2009-10-26 20:58:47','2009-10-26 20:58:47'),(22,'dude','2009-10-26 20:58:47','2009-10-26 20:58:47'),(23,'beach','2009-10-26 21:01:20','2009-10-26 21:01:20'),(24,'bikini','2009-10-26 21:01:20','2009-10-26 21:01:20'),(25,'cigar','2009-10-27 07:07:53','2009-10-27 07:07:53'),(26,'splendid','2009-10-27 07:07:53','2009-10-27 07:07:53'),(27,'rock','2009-10-27 07:07:53','2009-10-27 07:07:53'),(28,'roll','2009-10-27 07:07:53','2009-10-27 07:07:53'),(29,'rocket ship','2009-10-29 02:18:14','2009-10-29 02:18:14'),(30,'landscape','2009-10-29 02:22:44','2009-10-29 02:22:44'),(31,'Mt. Tam','2009-10-29 02:22:44','2009-10-29 02:22:44'),(32,'chicken','2009-10-29 04:07:35','2009-10-29 04:07:35'),(33,'rooster','2009-10-29 04:07:35','2009-10-29 04:07:35'),(34,'encaustic','2009-10-29 04:07:35','2009-10-29 04:07:35'),(35,'dk haas','2009-10-29 04:07:35','2009-10-29 04:07:35'),(36,'koi','2009-10-29 04:34:22','2009-10-29 04:34:22'),(37,'carp','2009-10-29 04:34:22','2009-10-29 04:34:22'),(38,'lily pads','2009-10-29 04:34:22','2009-10-29 04:34:22'),(39,'cock','2009-10-29 04:38:55','2009-10-29 04:38:55'),(40,'mod','2009-10-29 04:38:55','2009-10-29 04:38:55'),(41,'paintings','2009-10-29 04:43:12','2009-10-29 04:43:12'),(42,'Tree','2009-11-02 04:00:17','2009-11-02 04:00:17'),(43,'trees','2009-11-02 04:00:17','2009-11-02 04:00:17'),(44,'red abstract','2009-11-02 04:00:17','2009-11-02 04:00:17'),(45,'modern','2009-11-02 04:00:17','2009-11-02 04:00:17'),(46,'red','2009-11-02 04:02:36','2009-11-02 04:02:36'),(47,'abstract','2009-11-02 04:02:36','2009-11-02 04:02:36'),(48,'yellow','2009-11-02 04:26:31','2009-11-02 04:26:31'),(49,'black','2009-11-02 04:26:31','2009-11-02 04:26:31'),(50,'test','2009-11-02 05:35:28','2009-11-02 05:35:28'),(51,'whatever','2009-11-02 05:35:28','2009-11-02 05:35:28'),(52,'train tracks. wack','2009-11-02 06:02:12','2009-11-02 06:02:12'),(53,'pack slack','2009-11-02 06:02:12','2009-11-02 06:02:12'),(54,'bunny','2009-11-03 00:18:05','2009-11-03 00:18:05'),(55,'bunnymatic','2009-11-03 00:18:05','2009-11-03 00:18:05');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-11-06  1:44:11
