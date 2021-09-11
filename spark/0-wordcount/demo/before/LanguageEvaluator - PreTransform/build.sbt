name := "Language Evaluator"

version := "0.1"

scalaVersion := "2.10.5"

libraryDependencies += "org.apache.spark" % "spark-core_2.10" % "1.4.0" % "provided"

libraryDependencies += "org.apache.hadoop" % "hadoop-streaming" % "2.6.0"

assemblyJarName in assembly := s"${name.value.replace(' ','-')}-${version.value}.jar"

assemblyOption in assembly := (assemblyOption in assembly).
                                    value.copy(includeScala = false)