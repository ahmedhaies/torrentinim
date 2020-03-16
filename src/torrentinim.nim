# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
import htmlgen
import jester
import json
import threadpool
import json
import strutils

import database
import /helpers/datetime
from /crawlers/eztv import nil
from /crawlers/leetx import nil

# discard init_database()
# spawn eztv.start_crawl()
# spawn leetx.start_crawl()

# TODO: Make sure all torrents datetimes are saved in uniform pattern.

when isMainModule:
  routes:
    get "/search":
      if request.params.hasKey("q") and request.params.hasKey("page"):
        let q = request.params["q"]
        let page = parseInt(request.params["page"])
        resp(Http200, $(%search(q, page)) , contentType="application/json")
      else:
        resp(Http200, "Params: `q` and `page` must be present")
    get "/latest":
      resp(Http200, $(%all_torrents()) , contentType="application/json")
