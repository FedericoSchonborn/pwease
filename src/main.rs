#![warn(clippy::pedantic, clippy::cargo)]

use std::{env, process::Command};

use anyhow::{Context, Result};

fn main() -> Result<()> {
    let mut args = env::args().skip(1);

    let program = &args.next().context("program argument(s) missing")?;
    let rest: Vec<_> = args.collect();
    loop {
        let mut child = Command::new(program).args(&rest).spawn()?;
        let status = child.wait()?;
        if status.success() {
            break;
        }
    }

    Ok(())
}
