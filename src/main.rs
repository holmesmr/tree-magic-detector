use std::{env, path};
use anyhow::Context;

fn main() -> anyhow::Result<()> {
    let mut args = env::args();
    let prog_name = args.next().expect("OS must pass program name");
    let filename =  if let Some(filename) = args.next() {
        filename
    } else {
        eprintln!("usage: {} <filename>", prog_name);
        anyhow::bail!("Incorrect command line parameters");
    };

    let path = path::Path::new(&filename);

    let detected_mime = tree_magic_mini::from_filepath(path).ok_or_else(|| anyhow::anyhow!("Could not detect MIME type for {}", &filename))?;

    println!("Detected mime type is {}", detected_mime);

    Ok(())
}
