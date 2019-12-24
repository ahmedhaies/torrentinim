# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
import htmlgen
import jester
import json
import threadpool
import json

import database
import /helpers/datetime
from /crawlers/eztv import nil
from /crawlers/leetx import nil

discard init_database()
spawn eztv.start_crawl()
spawn leetx.start_crawl()

when isMainModule:
  routes:
    get "/":
      resp %all_torrents()
