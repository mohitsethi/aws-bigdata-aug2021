package main

import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

object WordCounter {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("Word Counter")
    val sc = new SparkContext(conf)
    val textFile = sc.textFile("file:///appdata/input.txt")
    val tokenizedFileData = textFile.flatMap(line=>line.split(" "))
    val countPrep = tokenizedFileData.map(word=>(word, 1))
    val counts = countPrep.reduceByKey((accumValue, newValue)=>accumValue + newValue)
    val sortedCounts = counts.sortBy(kvPair=>kvPair._2, false)
    sortedCounts.saveAsTextFile("file:///appdata/spark/output")
  }
}