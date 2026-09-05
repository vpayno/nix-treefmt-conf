#!/usr/bin/env python
"""
Code Owners formatter.
- ignore lines starting with # or [
- ignore blank lines
- format the rest of the lines like `column -t` would

file: "${MYVIMDIR:=${HOME}}"/.vim/scripts/scripts/fmt-codeowners.py
"""

import argparse
import sys
from typing import TextIO

from rich.traceback import install

# import vim

_ = install()  # setup rich


def format_buffer(old_buffer: TextIO | list[str]) -> list[str]:
    """Takes in a list of strings and returns a new list of formatted strings."""
    buffer: list[str] = []
    new_buffer: list[str] = []

    max_size: dict[int, int] = {}

    line: str
    word_token: str
    index_token: int
    index_names: int
    line_tokens: list[str]

    for line in old_buffer:
        buffer.append(line.rstrip("\r\n"))

    for line in buffer:
        if line.startswith(("#", "[")) or len(line) == 0:
            continue

        for index_token, word_token in enumerate(line.split()):
            max_size[index_token] = max(len(word_token), max_size.get(index_token, 0))

    for line in buffer[:]:
        if line.startswith(("#", "[")) or len(line) == 0:
            new_buffer.append(line)
            continue

        line_tokens = line.split()
        for index_token, word_token in enumerate(line_tokens):
            max_size[index_token] = max(len(word_token), max_size.get(index_token, 0))

        new_line: str = line_tokens[0].ljust(max_size.get(0, 0) + 8, " ")

        index_names = 1  # starting on the 2nd token
        for word_token in line.split()[1:]:
            new_line += word_token.ljust(max_size[index_names] + 1, " ")
            index_names += 1

            new_buffer.append(new_line)

    return new_buffer


def main() -> None:
    """Runs the cli code."""
    stdin_mode: bool = False

    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        prog="fmt-codeowners",
        description="CODEOWNERS formatter",
    )
    # "paths", default=[sys.stdin], type=argparse.FileType("r"), nargs="*"
    # paths: list[TextIO | str]
    _ = parser.add_argument(
        "paths",
        default=[sys.stdin],
        type=str,
        nargs="*",
    )
    args: argparse.Namespace = parser.parse_args()

    for filename in args.paths:
        if filename in [sys.stdin, "-"]:
            stdin_mode = True
            break

    buffer_line: str

    if stdin_mode:
        buffer_final = format_buffer(sys.stdin)
        for buffer_line in buffer_final:
            print(buffer_line, end="\n")
    else:
        buffer_prev: list[str] = []
        buffer_final: list[str] = []

        for filename in args.paths:
            with open(filename, mode="r", encoding="utf-8") as f:
                buffer_prev = f.readlines()
                buffer_final = format_buffer(buffer_prev)

            with open(filename, mode="w", encoding="utf-8") as f:
                f.writelines([line + "\n" for line in buffer_final])


if __name__ == "__main__":  # pragma: no cover
    main()
