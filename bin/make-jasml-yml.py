#!/usr/bin/env python

import sys
import time
import re
import yaml
from pathlib import Path
import argparse


def input_file(path_str: str) -> Path:
    path = Path(path_str)
    if not path.is_file():
        raise argparse.ArgumentTypeError(f"File does not exist: {path}")
    return path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Process two input files and write an output file."
    )

    parser.add_argument("env_file",
                        type=input_file,
                        help="JASPY environment file (e.g. core-packages.yml)")

    parser.add_argument("diffs_file",
                        type=input_file,
                        help="file with diffs for JasML (e.g. jasml-diffs.yml)")
    
    parser.add_argument("out_file",
                        type=Path,
                        help="Output file to create (e.g. jasml.yml)")

    parser.add_argument("-O", "--overwrite",
                        action="store_true",
                        help="overwrite without confirmation")

    return parser.parse_args()


def load_yaml(path: Path):
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


class CondaStyleDumper(yaml.SafeDumper):
    def increase_indent(self, flow=False, indentless=False):
        return super().increase_indent(flow, False)


def dump_yaml(path, data, comments=None):
    with path.open("w", encoding="utf-8") as f:
        if comments:
            for comment in comments:
                f.write(f"# {comment}\n")
            f.write("\n")            
        yaml.dump(
            data,
            f,
            Dumper=CondaStyleDumper,
            default_flow_style=False,
            sort_keys=False,
            allow_unicode=True,
        )


def apply_diffs(packages, diffs):
    adds = diffs.get("require") or []
    removes = diffs.get("exclude") or []
    out_list = do_removes(packages, removes)
    out_list.extend(adds)
    return out_list


def do_removes(packages, removes):
    removes = set(removes)
    packages_out = []
    for pack in packages:
        unversioned = get_package_name(pack)
        if unversioned not in removes:
            packages_out.append(pack)
    return packages_out


def get_package_name(spec: str) -> str:
    spec = spec.strip()
    m = (re.match(r'git+.*/([^/]+)\.git\b', spec)
         or re.match(r'^([A-Za-z0-9_.-]+)', spec))
    if not m:
        raise ValueError(f"Could not parse package name from: {spec!r}")
    return m.group(1)


def full_path(path_str: str) -> str:
    return Path(path_str).resolve()


def main():
    args = parse_args()

    out_file = args.out_file
    if not args.overwrite and Path(out_file).exists():
        if not input(f"overwrite {out_file} [yN]? ").lower().startswith("y"):
            print("Aborting")
            sys.exit(1)

    env_data = load_yaml(args.env_file)
    diff_data = load_yaml(args.diffs_file)

    #print(env_data)
    #print(diff_data)

    deps = env_data.get("dependencies", {})
    conda_jaspy = [s for s in deps if isinstance(s, str)]
    try:
        pip_jaspy, = [d["pip"] for d in deps if isinstance(d, dict)
                      and "pip" in d]
    except ValueError:
        pip_jaspy = []
    
    conda_diffs = diff_data.get("conda") or {}
    pip_diffs = diff_data.get("pip") or {}

    conda_out = apply_diffs(conda_jaspy, conda_diffs)
    pip_out = apply_diffs(pip_jaspy, pip_diffs)

    out_data = env_data.copy()
    out_data["dependencies"] = conda_out + [{"pip": pip_out}]

    out_comments = []
    extra_comments = diff_data.get("comments")
    if extra_comments:
        out_comments.extend(extra_comments + [""])
    out_comments.extend(
        [f"Auto generated at {time.asctime()}",
         f"   env file: {full_path(args.env_file)}",
         f" diffs file: {full_path(args.diffs_file)}",
         f"using script: {full_path(__file__)}"]
        )
    
    dump_yaml(out_file, out_data, comments=out_comments)
    print(f"Wrote {out_file}")
    
if __name__ == "__main__":
    main()
