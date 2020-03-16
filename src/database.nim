import db_sqlite
import torrent
import strformat
import strutils
import times
import json

proc init_database*(): string =
  let db = open("torrentinim-data.db", "", "", "")

  db.exec(sql"DROP TABLE IF EXISTS torrents")
  db.exec(sql"PRAGMA case_sensitive_like = true;")
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
  db.exec(sql"""CREATE INDEX torrents_name ON torrents(name)""")
  db.close()


proc insert_torrent*(torrent: Torrent): bool =
  echo &"[database] Saving torrent: {torrent}"

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
  let torrents = db.getAllRows(sql"SELECT uploaded_at, name, canonical_url, magnet_url, size, seeders, leechers FROM torrents")
  for row in torrents:
    result.add(
      Torrent(
        uploaded_at: parse(row[0], "yyyy-MM-dd'T'HH:mm:sszzz"),
        name: row[1],
        canonical_url: row[2],
        magnet_url: row[3],
        size: row[4],
        seeders: parseInt(row[5]),
        leechers: parseInt(row[6])
      )
    ) #2019-12-23T23:15:41-05:00
  db.close()

proc search*(query: string, page: int): seq[Torrent] =
  echo query
  let perPage = 5
  let skip = if page == 1: 0 else: page * perPage
  let db = open("torrentinim-data.db", "", "", "")
  let torrents = db.getAllRows(sql"SELECT name, canonical_url, uploaded_at FROM torrents WHERE name LIKE '%' || ? || '%' LIMIT ?, ?", query, skip, perPage)

  for row in torrents:
    result.add(
      Torrent(
        uploaded_at: parse(row[0], "yyyy-MM-dd'T'HH:mm:sszzz"),
        name: row[1],
        canonical_url: row[2],
        magnet_url: row[3],
        size: row[4],
        seeders: parseInt(row[5]),
        leechers: parseInt(row[6])
      )
    )
  db.close()