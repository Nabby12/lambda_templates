module App

function handler(event)
    println("-- Start function --")

    println(event["key"])

    println("-- Exit function --")
end

function main(event, headers)
    event = parse(Int, event)
    handler(event)

    return "exit function"
end

if abspath(PROGRAM_FILE) == @__FILE__
    app.main(event, headers)
end

end # module
