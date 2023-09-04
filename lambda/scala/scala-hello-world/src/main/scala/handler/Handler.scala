package handler

import scala.collection.JavaConverters._
import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler

trait HandlerBase {
  def handler(event: String, context: Context): java.util.List[String] = {
    println("-- Start function --")

    println(event)

    println("-- Exit function --")

    List("%d".format("exit function")).asJava
  }
}

class Handler extends HandlerBase
