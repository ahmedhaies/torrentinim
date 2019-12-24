import db_sqlite
import torrent
import strformat
import times

proc init_database*(): string =
  let db = open("torrentinim-data.db", "", "", "")

  db.exec(sql"DROP TABLE IF EXISTS torrents")
  echo "[database] Initializing database if necessary."
  db.exec(sql"""CREATE TABLE IF NOT EXISTS torrents (
                  id            INTEGER PRIMARY KEY,
                  uploaded_at   DATETIME NOT NULL,
                  name          TEXT NOT NULL,
                  canonical_url TEXT NOT NULL,
                  magnet_url    TEXT NOT NULL,
                  size          TEXT NOT NULL,
                  seeders       INTEGER,
                  leechers      INTEGER
                )""")
  db.exec(sql"""CREATE UNIQUE INDEX torrents_unique_canonical_url ON torrents(canonical_url)""")
  db.close()


proc insert_torrent*(torrent: Torrent): bool =
  echo &"[database] Saving torrent: {torrent.canonical_url}"

  let db = open("torrentinim-data.db", "", "", "")
  result = db.tryInsertID(sql"INSERT INTO torrents (uploaded_at, name, canonical_url, magnet_url, size, seeders, leechers) VALUES (?, ?, ?, ?, ?, ?, ?)",
    torrent.uploaded_at,
    torrent.name,
    torrent.canonical_url,
    torrent.magnet_url,
    torrent.size,
    torrent.seeders,
    torrent.leechers
  ) != -1
  db.close()

proc all_torrents*(): seq[Torrent] =
  let db = open("torrentinim-data.db", "", "", "")
  let torrents = db.getAllRows(sql"SELECT name, canonical_url, uploaded_at FROM torrents")
  for row in torrents:
    result.add(Torrent(name: row[0], canonical_url: row[1], uploaded_at: parse(row[2], "yyyy-MM-dd'T'HH:mm:sszzz"))) #2019-12-23T23:15:41-05:00
  db.close()