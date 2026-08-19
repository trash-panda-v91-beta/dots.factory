# TODO: remove once upstream fixes the bare {" "} text node in s3.tsx
# https://github.com/raycast/extensions/blob/main/extensions/amazon-aws/src/s3.tsx
import pathlib
p = pathlib.Path("src/s3.tsx")
p.write_text(p.read_text().replace('{" "}', ""))
