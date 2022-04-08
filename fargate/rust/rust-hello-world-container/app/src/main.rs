use std::env;
use std::process;
use std::time::Instant;

#[tokio::main]
async fn main() {
    let start = Instant::now();
    println!("-- Start function --");

    let os_env = match env::var("ENV") {
        Ok(value) => value,
        Err(err) => {
            println!("{}: {}", err, "ENV");
            process::exit(1);
        },
    };
    println!("Env: {}", os_env);

    let end = start.elapsed();
    println!("Time: {}.{:03}sec", end.as_secs(), end.subsec_nanos() / 1_000_000);
    println!("-- Exit function --");
}
