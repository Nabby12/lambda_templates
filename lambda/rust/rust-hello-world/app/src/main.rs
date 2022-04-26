use std::env;
use std::process;

use lambda_runtime::{service_fn, LambdaEvent, Error};
use serde_json::{json, Value};

async fn handler(event: LambdaEvent<Value>) -> Result<Value, Error> {
    println!("-- Start function --");

    let os_env: String = get_env("ENV").await;
    println!("Env: {}", os_env);

    let (event, _context) = event.into_parts();
    let event_value = event["key"].as_str().unwrap_or("key is not existed");

    println!("{}", format!("{}!", event_value));

    println!("-- Exit function --");

    Ok(json!({ "message": format!("return_message: {}!", event_value) }))
}

async fn get_env(key: &str) -> String {
    let os_value = match env::var(key) {
        Ok(value) => value,
        Err(err) => {
            println!("{}: {}", err, key);
            process::exit(1);
        },
    };

    os_value.to_string()
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    let func = service_fn(handler);
    lambda_runtime::run(func).await?;
    Ok(())
}
