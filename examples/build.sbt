// Targets Scala3 LTS
val scala3Version = "3.3.5"

lazy val root = project
  .in(file("."))
  .settings(
    name := "fs2-backpressure-sensor-examples",
    scalaVersion := scala3Version,
    
    libraryDependencies ++= Seq(
      "io.github.nivox" %% "fs2-backpressure-sensor" % "0.0.1",
      "org.jline" % "jline" % "3.25.1"
    )
  )
