CREATE DATABASE PublisherDW
GO
USE PublisherDW;
GO
CREATE TABLE titles_dim
( TitleKey INT NOT NULL IDENTITY,
title_id CHAR(20),
title VARCHAR(80),
type char(12),
price money,
advance money,
royalty int,
ytd_sales int,
PRIMARY KEY (TitleKey));
GO
CREATE TABLE roysched_dim
(royschedKey INT NOT NUll IDENTITY,
title_id	char(20),
lorange int,
hirange int,
royalty int,
PRIMARY KEY (royschedKey));
GO
CREATE TABLE titleauthor_dim
(titleauthorKey INT NOT NUll IDENTITY,
title_id	char(20),
au_ord tinyint,
royaltyper int,
PRIMARY KEY (titleauthorKey));
GO
CREATE TABLE author_Fact
(
TitleKey INT,
royschedKey INT,
titleauthorKey INT,
au_id CHAR(20),
amountpaid INT,
PRIMARY KEY(TitleKey, au_id),
FOREIGN KEY (TitleKey) REFERENCES titles_dim (TitleKey),
FOREIGN KEY (royschedKey) REFERENCES roysched_dim (royschedKey),
FOREIGN KEY (titleauthorKey) REFERENCES titleauthor_dim (titleauthorKey)
);