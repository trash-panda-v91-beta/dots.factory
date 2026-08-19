import pathlib
p = pathlib.Path("src/s3.tsx")
p.write_text(p.read_text().replace('{" "}', ""))
