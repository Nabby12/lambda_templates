import Dependencies._

ThisBuild / scalaVersion     := "2.13.8"
ThisBuild / version          := "0.1.0-SNAPSHOT"
ThisBuild / organization     := "com.handler"
ThisBuild / organizationName := "handler"

lazy val root = (project in file("."))
  .settings(
    name := "scala-hello-world",
    libraryDependencies ++= Seq(
      scalaTest % Test,
      "com.amazonaws" % "aws-lambda-java-core" % "1.1.0",
      "com.amazonaws" % "aws-lambda-java-events" % "1.1.0"
    ),
    assemblyMergeStrategy in assembly := {
      case PathList(ps @ _*) if ps.last endsWith ".class" => MergeStrategy.first
      case x =>
        val oldStrategy = (assemblyMergeStrategy in assembly).value
        oldStrategy(x)
    }
  )
