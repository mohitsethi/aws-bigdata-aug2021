package main

import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.apache.hadoop.streaming.StreamXmlRecordReader
import org.apache.hadoop.mapred.JobConf 
import org.apache.hadoop.io.Text
import org.apache.hadoop.mapred.FileInputFormat
import scala.xml.XML

object Evaluator {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("Language Evaluator")
    val sc = new SparkContext(conf)
    val jobConf = new JobConf()
    jobConf.set("stream.recordreader.class", 
                "org.apache.hadoop.streaming.StreamXmlRecordReader")
    jobConf.set("stream.recordreader.begin", "<page>")
    jobConf.set("stream.recordreader.end", "</page>")
    FileInputFormat.addInputPaths(jobConf, "file:///Data/WikiPages_BigData.xml") 

    val wikiDocuments = sc.hadoopRDD(jobConf, 
	  classOf[org.apache.hadoop.streaming.StreamInputFormat],
      classOf[Text], classOf[Text])

	val deHadoopedWikis = wikiDocuments.map(hadoopXML=>hadoopXML._1.toString)
	
	val rawWikiPages = deHadoopedWikis.map(wikiString=>{
	  val wikiXML = XML.loadString(wikiString)
	  val wikiPageText = (wikiXML \ "revision" \ "text").text
	  WikiCleaner.parse(wikiPageText)
	})
	
	val tokenizedWikiData = rawWikiPages.flatMap(wikiText=>wikiText.split(" "))
	val pertinentWikiData = tokenizedWikiData
	                        .map(wikiToken => wikiToken.replaceAll("[.|,|'|\"|?|)|(]", "").trim)
	                        .filter(wikiToken=>wikiToken.length > 2)
	                        
	val wikiDataSortedByLength = pertinentWikiData.distinct
	         .sortBy(wikiToken=>wikiToken.length, ascending = false)
	         .sample(withReplacement = false, fraction = .01)
	         
	wikiDataSortedByLength.collect.foreach(println)
  }
}