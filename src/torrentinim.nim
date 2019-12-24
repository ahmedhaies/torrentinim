# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
import htmlgen
import jester
import json
import threadpool
import json

import database
import /crawlers/eztv

# discard init_database()
# spawn start_crawl()

when isMainModule:
  routes:
    get "/":
      resp $(%*(all_torrents()))
