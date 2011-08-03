-- See contents of places.sqlite in profile directory...
-- Also, see about grabbing the 'bookmarkbackups' directory.

-- sqlite> .tables
-- moz_anno_attributes  moz_favicons         moz_keywords       
-- moz_annos            moz_historyvisits    moz_places         
-- moz_bookmarks        moz_inputhistory   
-- moz_bookmarks_roots  moz_items_annos
-- 
-- 
-- sqlite> select * from moz_anno_attributes;
-- 1|bookmarkProperties/description
-- 2|placesInternal/READ_ONLY
-- 3|livemark/feedURI
-- 4|livemark/siteURI
-- 5|Places/SmartBookmark
-- 7|livemark/expiration
-- 
-- sqlite> select * from moz_annos;
-- sqlite> select * from moz_keywords;
-- 
-- sqlite> select * from moz_places;
-- 1|http://www.mozilla.com/en-US/firefox/central/||moc.allizom.www.|0|0|0||140||ek1f6Qe8dYm-
-- 2|http://www.mozilla.com/en-US/firefox/help/||moc.allizom.www.|0|0|0|1|140||X1_8M2PEwvPg
-- 3|http://www.mozilla.com/en-US/firefox/customize/||moc.allizom.www.|0|0|0|2|140||sPYLdFugps49
-- 4|http://www.mozilla.com/en-US/firefox/community/||moc.allizom.www.|0|0|0|3|140||quq04KE_sTDo
-- ...
-- 
-- sqlite> select * from moz_bookmarks;
-- 1|2||0|0||||1310079919569949|1310079919570865|KH8lgyfoWhSz
-- 2|2||1|0|Bookmarks Menu|||1310079919570161|1310079919680512|lkE99lM3V-f0
-- 3|2||1|1|Bookmarks Toolbar|||1310079919570500|1310079919678949|mYmP-K3Xxcj_
-- 4|2||1|2|Tags|||1310079919570677|1310079919570843|YRd3ad7OZQwH
-- 5|2||1|3|Unsorted Bookmarks|||1310079919570865|1310079919666676|4_rQM0qRi0QR
-- 6|1|1|3|1|Getting Started|||1310079919667533|1310079919667849|0lr_KuBGq1Gx
-- 7|2||3|2|Latest Headlines|||1310079919667944|1312077389388184|v3TJNmkCiMN9
-- 8|2||2|3|Mozilla Firefox|||1310079919668369|1310079919671024|Npg7W2AMWeLC
-- 9|1|2|8|0|Help and Tutorials|||1310079919668581|1310079919669333|go6huHg5fCMW
-- 10|1|3|8|1|Customize Firefox|||1310079919669663|1310079919670123|cOe0IQidhp6H
-- 11|1|4|8|2|Get Involved|||1310079919670322|1310079919670792|Gx_c_GURucvf
-- ...
-- 
-- sqlite> select * from moz_bookmarks_roots;
-- places|1
-- menu|2
-- toolbar|3
-- tags|4
-- unfiled|5
-- 
-- sqlite> select * from moz_items_annos;
-- 1|3|1||Add bookmarks to this folder to see them displayed on the Bookmarks Toolbar|0|4|3|1310079919667017|1310079919667019
-- 2|7|2||1|0|4|1|1310079919668033|1310079919668035
-- 3|7|3||http://fxfeeds.mozilla.com/en-US/firefox/headlines.xml|0|4|3|1310079919668141|1310079919668143
-- 4|7|4||http://www.bbc.co.uk/go/rss/int/news/-/news/|0|4|3|1310079919668279|1310079943662175
-- 5|13|5||MostVisited|0|4|3|1310079919679326|1310079919679329
-- 6|14|5||RecentlyBookmarked|0|4|3|1310079919679899|1310079919679901
-- 7|15|5||RecentTags|0|4|3|1310079919680366|1310079919680367
-- 8|7|7||1312080989388.0|0|4|2|1310079943847473|1312077389388083

CREATE TABLE moz_anno_attributes (
  id INTEGER PRIMARY KEY,
  name VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE moz_annos (
  id INTEGER PRIMARY KEY,
  place_id INTEGER NOT NULL,
  anno_attribute_id INTEGER,
  mime_type VARCHAR(32) DEFAULT NULL,
  content LONGVARCHAR,
  flags INTEGER DEFAULT 0,
  expiration INTEGER DEFAULT 0,
  type INTEGER DEFAULT 0,
  dateAdded INTEGER DEFAULT 0,
  lastModified INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX moz_annos_placeattributeindex ON moz_annos (place_id, anno_attribute_id);

CREATE TABLE moz_keywords (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword TEXT UNIQUE
);

CREATE TABLE moz_places (
  id INTEGER PRIMARY KEY,
  url LONGVARCHAR,
  title LONGVARCHAR,
  rev_host LONGVARCHAR,
  visit_count INTEGER DEFAULT 0,
  hidden INTEGER DEFAULT 0 NOT NULL,
  typed INTEGER DEFAULT 0 NOT NULL,
  favicon_id INTEGER,
  frecency INTEGER DEFAULT -1 NOT NULL,
  last_visit_date INTEGER,
  guid TEXT
);
CREATE INDEX moz_places_faviconindex ON moz_places (favicon_id);
CREATE INDEX moz_places_frecencyindex ON moz_places (frecency);
CREATE UNIQUE INDEX moz_places_guid_uniqueindex ON moz_places (guid);
CREATE INDEX moz_places_hostindex ON moz_places (rev_host);
CREATE INDEX moz_places_lastvisitdateindex ON moz_places (last_visit_date);
CREATE UNIQUE INDEX moz_places_url_uniqueindex ON moz_places (url);
CREATE INDEX moz_places_visitcount ON moz_places (visit_count);

CREATE TABLE moz_bookmarks (
  id INTEGER PRIMARY KEY,
  type INTEGER,
  fk INTEGER DEFAULT NULL,
  parent INTEGER,
  position INTEGER,
  title LONGVARCHAR,
  keyword_id INTEGER,
  folder_type TEXT,
  dateAdded INTEGER,
  lastModified INTEGER,
  guid TEXT
);
CREATE UNIQUE INDEX moz_bookmarks_guid_uniqueindex ON moz_bookmarks (guid);
CREATE INDEX moz_bookmarks_itemindex ON moz_bookmarks (fk, type);
CREATE INDEX moz_bookmarks_itemlastmodifiedindex ON moz_bookmarks (fk, lastModified);
CREATE INDEX moz_bookmarks_parentindex ON moz_bookmarks (parent, position);
CREATE TRIGGER moz_bookmarks_beforedelete_v1_trigger BEFORE DELETE ON moz_bookmarks FOR EACH ROW WHEN OLD.keyword_id NOT NULL BEGIN DELETE FROM moz_keywords WHERE id = OLD.keyword_id AND NOT EXISTS ( SELECT id FROM moz_bookmarks WHERE keyword_id = OLD.keyword_id AND id <> OLD.id LIMIT 1 );END;

CREATE TABLE moz_bookmarks_roots (
  root_name VARCHAR(16) UNIQUE,
  folder_id INTEGER
);

CREATE TABLE moz_items_annos (
  id INTEGER PRIMARY KEY,
  item_id INTEGER NOT NULL,
  anno_attribute_id INTEGER,
  mime_type VARCHAR(32) DEFAULT NULL,
  content LONGVARCHAR,
  flags INTEGER DEFAULT 0,
  expiration INTEGER DEFAULT 0,
  type INTEGER DEFAULT 0,
  dateAdded INTEGER DEFAULT 0,
  lastModified INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX moz_items_annos_itemattributeindex ON moz_items_annos (item_id, anno_attribute_id);

CREATE TABLE moz_anno_attributes (
  id INTEGER PRIMARY KEY,
  name VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE moz_favicons (
  id INTEGER PRIMARY KEY,
  url LONGVARCHAR UNIQUE,
  data BLOB,
  mime_type VARCHAR(32),
  expiration LONG
);
