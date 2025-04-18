import fs2.Stream
import fs2.backpressuresensor.syntax.*

import cats.effect.{IO, IOApp}
import scala.concurrent.duration.*
import fs2.backpressuresensor.Reporter

object Example2 extends ExampleApp:
  val stream = s =>
    s.backpressureBracketSensor(reporter("pipe1"))(controlledPipe("pipe1"))
      .backpressureBracketSensor(reporter("pipe2"))(controlledPipe("pipe2"))
