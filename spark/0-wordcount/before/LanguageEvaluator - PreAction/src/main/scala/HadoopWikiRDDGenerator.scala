package main

import org.apache.spark.SparkContext
import org.apache.hadoop.streaming.StreamXmlRecordReader
import org.apache.hadoop.mapred.JobConf 
import org.apache.hadoop.io.Text 

object HadoopWikiRDDGenerator{
  def createUsing(sc: SparkContext, withPath: String) = {
    val jobConf = new JobConf()
    jobConf.set("stream.recordreader.class", "org.apache.hadoop.streaming.StreamXmlRecordReader")
    jobConf.set("stream.recordreader.begin", "<page>")
    jobConf.set("stream.recordreader.end", "</page>")
    org.apache.hadoop.mapred.FileInputFormat.addInputPaths(jobConf, withPath) 

    sc.hadoopRDD(jobConf, classOf[org.apache.hadoop.streaming.StreamInputFormat], classOf[Text], classOf[Text])
  }
}