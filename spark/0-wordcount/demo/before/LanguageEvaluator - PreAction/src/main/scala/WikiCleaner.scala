package main

import org.apache.spark.rdd.RDD
import scala.xml.XML
import org.apache.hadoop.io.Text 

//Rough port from https://github.com/joaomsa/txtwiki.js
case class TempParsed(text: Option[String], pos: Int)
object WikiCleaner {
  def clean(wikiDocuments: RDD[(Text, Text)]) = {
    val deHadoopedWikis = wikiDocuments.map(hadoopXML=>hadoopXML._1.toString)
	
	//Shows that multiple lines
	deHadoopedWikis.map(wikiString=>{
	  val wikiXML = XML.loadString(wikiString)
	  val wikiPageText = (wikiXML \ "revision" \ "text").text
	  WikiCleaner.parse(wikiPageText)
	})
  }
  
def parse(contentVal: String) = {
  var content = contentVal
  var parsed = ""
  content = stripWhitespace(content)
  content = firstPass(content)
  content = secondPass(content)
  var paragraphs = content.split("\n")
  paragraphs.foreach(paragraph=>{
    if(paragraph.length == 0) parsed += "\n"
    else parsed += paragraph + "\n"
  })
  parsed = stripWhitespace(parsed).replace("'", "").replace("*", "").replace("#", "")
  parsed
}

def stripWhitespace(contentVal: String) = {
  var parsed = "";
  var content = contentVal
  content = content.replaceAll(" +", " ")
  var blocks = content.split("\n")
  blocks.foreach(block=>
    if (block.matches("^\\s*$")) parsed += "\n\n"
    else if (block.matches("^==+.+==+$")) parsed += block + "\n"
    else parsed += block
  )
  parsed = parsed.replaceAll("\\n\\n+", "\n\n").replaceAll("(^\\n*|\\n*$)", "")
  parsed.trim
}

def firstPass(content: String) = {
  var parsed = ""
  var pos = 0
  while(pos < content.size){
    var out: Option[TempParsed] = None
	//Remove comments
    if(content(pos) == '<') out = parseSimpleTag(content, pos, "<!--", "-->")
	//Remove templates
	if(content.slice(pos, pos+2) == "{{") out = parseSimpleTag(content, pos, "{{", "}}")
    else if(content(pos) == '{') out = parseSimpleTag(content, pos, "{|", "|}")
	//Remove external links
	if(isExternalLink(content, pos)) out = parseSimpleTag(content, pos, "[", "]")
	//Remove Headers
	if(content.slice(pos, pos+3) == "===") out = parseSimpleTag(content, pos, "===", "===")
	else if(content.slice(pos, pos+2) == "==") out = parseSimpleTag(content, pos, "==", "==")

    out match {
      case Some(out) if (!out.text.isEmpty) => pos = out.pos
      case _ => {
        parsed += content(pos)
        pos = pos + 1
      }
    }
  }
  parsed
}

def isExternalLink(content: String, pos: Int) = 
  content(pos) == '[' && 
  content.slice(pos, pos+2) != "[[" && 
  content.slice(pos - 1, pos + 1) != "[["

def parseSimpleTag(content: String, posVal: Int, start: String, end: String) = {
  var pos = posVal
  if(content.slice(pos, pos + start.length) == start) {
    pos = pos + start.length
    var posEnd = content.indexOf(end, pos)
    if (posEnd == -1) posEnd = content.length
    Some(TempParsed(Option(content.slice(pos, posEnd)), posEnd + end.length))
  }
  else None
}

def secondPass(content: String) = {
  var parsed = ""
  var pos = 0
  while(pos < content.length){
    var out: Option[TempParsed] = None
    if(content(pos) == '<') out = parseRef(content, pos)
    if(content(pos) == '[') {
      out = parseLink(content, pos)
      out.map(x=>x.text.map(y=>parsed += y))
    }

    out match {
      case Some(out) if (!out.text.isEmpty) => pos = out.pos
      case _ => {
        parsed += content(pos)
        pos = pos + 1
      }
    }
  }
  parsed
}


def parseRef(content: String, posVal: Int) = {
  var pos = posVal
  if (content.slice(pos, pos + 4) == "<ref"){
    pos = pos + 4
    var text = content.slice(pos, content.length)
    var posEnd = (("<\\/ref>|\\/>".r findFirstMatchIn text) map (_.start)).getOrElse(0)
    if (text.slice(posEnd, posEnd + 6) == "</ref>") Some(TempParsed(Option(text.slice(0, posEnd)), pos + posEnd + 6))
    else Some(TempParsed(Option(text.slice(0, posEnd)), pos + posEnd + 2))
  } 
  else None
}

def parseLink(content: String, posVal: Int): Option[TempParsed] = {
  var pos = posVal
  if (content.slice(pos, pos + 2) == "[["){
    var link = ""
    pos = pos + 2
    while (content.slice(pos, pos + 2) != "]]"){
      if (content.slice(pos, pos + 2) == "[["){
        var out = parseLink(content, pos);
		out match {
          case Some(out) => {
            link += out.text;
            pos = out.pos;
          }
          case None => 
        }
      } 
      else {
        link += content(pos);
        pos = pos + 1;
      }
    }
    pos += 2;
    var args = link.split("\\|")
	if (args(0).slice(0, 5) == "File:") Some(TempParsed(Option(""), pos))
	else if(args(0).slice(0, 9) == "Category:") Some(TempParsed(Option(""), pos))
    else if (args.length == 1) Some(TempParsed(Option(args(0)), pos))
    else Some(TempParsed(Option(args(1)), pos))
  }
  else None
}
}