import httpClient
import streams
import xmlparser
import xmltree

type
    Torrent* = object
        name*: string
        canonical_url*: string

proc fetchXml(): XmlNode =
    var client = newHttpClient()
    let xml = client.getContent("https://eztv.io/ezrss.xml")
    let xmlStream = newStringStream(xml)
    return parseXML(xmlStream)

proc latest*(): seq[Torrent] =
    var xmlRoot = fetchXml()
    for item_node in xmlRoot.findAll("item"):
        var torrent: Torrent = Torrent()
        torrent.name = item_node.child("title").innerText
        torrent.canonical_url = item_node.child("link").innerText
        result.add(torrent)