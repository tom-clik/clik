#!/usr/bin/env python3
"""Generate class-driven equivalents of Clik's container-query stylesheets."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCES = ("columns", "forms", "grids", "images", "items", "menus", "navbuttons", "tabs")

CONTAINERS = {
    "body": "body",
    "button": ".button",
    "form": "form",
    "grid": ".grid",
    "image": ".cs-image",
    "item": ".item",
    "menu": "#menu",
    "tabs": ".cs-tabs",
    "xcol": "#xcol",
}


def matching_brace(css: str, opening: int) -> int:
    depth = 1
    quote = None
    comment = False
    i = opening + 1
    while i < len(css):
        if comment:
            if css.startswith("*/", i):
                comment = False
                i += 2
                continue
        elif quote:
            if css[i] == "\\":
                i += 2
                continue
            if css[i] == quote:
                quote = None
        elif css.startswith("/*", i):
            comment = True
            i += 2
            continue
        elif css[i] in "'\"":
            quote = css[i]
        elif css[i] == "{":
            depth += 1
        elif css[i] == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("unclosed CSS block")


def next_opening_brace(css: str, start: int) -> int:
    quote = None
    comment = False
    i = start
    while i < len(css):
        if comment:
            if css.startswith("*/", i):
                comment = False
                i += 2
                continue
        elif quote:
            if css[i] == "\\":
                i += 2
                continue
            if css[i] == quote:
                quote = None
        elif css.startswith("/*", i):
            comment = True
            i += 2
            continue
        elif css[i] in "'\"":
            quote = css[i]
        elif css[i] == "{":
            return i
        i += 1
    return -1


def slug(value: str) -> str:
    return re.sub(r"[^a-z0-9_-]+", "-", value.strip().lower()).strip("-")


def class_name(name: str, value: str) -> str:
    return f"clik-{name.removeprefix('--')}-{slug(value)}"


def condition_selectors(query: str) -> list[str]:
    """Turn the style-query boolean subset used by Clik into selector suffixes."""
    atom_pattern = re.compile(r"style\(\s*(--[\w-]+)\s*:\s*([^)]*?)\s*\)")
    atoms: list[tuple[str, str]] = []

    def atom(match: re.Match[str]) -> str:
        atoms.append((match.group(1), match.group(2)))
        return f" A{len(atoms) - 1} "

    expression = atom_pattern.sub(atom, query)
    tokens = re.findall(r"A\d+|\band\b|\bor\b|\bnot\b|[()]", expression)
    position = 0

    def parse_primary():
        nonlocal position
        if position < len(tokens) and tokens[position] == "not":
            position += 1
            node = parse_primary()
            if node[0] != "atom":
                raise ValueError(f"unsupported compound negation in {query!r}")
            return ("not", node)
        if position < len(tokens) and tokens[position] == "(":
            position += 1
            node = parse_or()
            if position >= len(tokens) or tokens[position] != ")":
                raise ValueError(f"unbalanced query {query!r}")
            position += 1
            return node
        if position < len(tokens) and tokens[position].startswith("A"):
            index = int(tokens[position][1:])
            position += 1
            return ("atom", index)
        raise ValueError(f"cannot parse query {query!r} at {tokens[position:]}")

    def parse_and():
        nonlocal position
        nodes = [parse_primary()]
        while position < len(tokens) and tokens[position] == "and":
            position += 1
            nodes.append(parse_primary())
        return nodes[0] if len(nodes) == 1 else ("and", nodes)

    def parse_or():
        nonlocal position
        nodes = [parse_and()]
        while position < len(tokens) and tokens[position] == "or":
            position += 1
            nodes.append(parse_and())
        return nodes[0] if len(nodes) == 1 else ("or", nodes)

    if not atoms:
        return [""]
    tree = parse_or()
    if position != len(tokens):
        raise ValueError(f"unparsed query tokens in {query!r}: {tokens[position:]}")

    def dnf(node) -> list[list[str]]:
        if node[0] == "atom":
            name, value = atoms[node[1]]
            return [[f".{class_name(name, value)}"]]
        if node[0] == "not":
            name, value = atoms[node[1][1]]
            return [[f":not(.{class_name(name, value)})"]]
        if node[0] == "or":
            return [part for child in node[1] for part in dnf(child)]
        combinations = [[]]
        for child in node[1]:
            combinations = [left + right for left in combinations for right in dnf(child)]
        return combinations

    return ["".join(parts) for parts in dnf(tree)]


def split_selectors(selector: str) -> list[str]:
    parts, start, depth, quote = [], 0, 0, None
    for index, char in enumerate(selector):
        if quote:
            if char == quote:
                quote = None
        elif char in "'\"":
            quote = char
        elif char in "([":
            depth += 1
        elif char in ")]":
            depth -= 1
        elif char == "," and depth == 0:
            parts.append(selector[start:index].strip())
            start = index + 1
    parts.append(selector[start:].strip())
    return parts


def transform(
    css: str,
    source: str,
    contexts: list[list[tuple[str, str]]] | None = None,
) -> str:
    contexts = contexts or [[]]
    output, cursor = [], 0
    while cursor < len(css):
        opening = next_opening_brace(css, cursor)
        if opening < 0:
            output.append(css[cursor:])
            break
        header = css[cursor:opening]
        closing = matching_brace(css, opening)
        body = css[opening + 1:closing]
        stripped = re.sub(r"/\*.*?\*/", "", header, flags=re.S).strip()

        container = re.match(r"@container\s+([\w-]+)\s*(.*)", stripped, re.S)
        if container:
            name, query = container.groups()
            base = ".menu" if name == "menu" and source == "menus" else CONTAINERS[name]
            suffixes = condition_selectors(query)
            nested = []
            for context in contexts:
                for suffix in suffixes:
                    branch = list(context)
                    if branch and branch[-1][0] == name:
                        previous_name, previous_selector = branch[-1]
                        branch[-1] = (previous_name, previous_selector + suffix)
                    else:
                        branch.append((name, base + suffix))
                    nested.append(branch)
            output.append(transform(body, source, nested))
        elif stripped.startswith(("@media", "@supports", "@layer", "@document")):
            output.append(header + "{" + transform(body, source, contexts) + "}")
        elif contexts != [[]]:
            prefixes = [" ".join(selector for _, selector in context) for context in contexts]
            selectors = [f"{prefix} {item}" for prefix in prefixes for item in split_selectors(header)]
            output.append(",\n".join(selectors) + "{" + body + "}")
        else:
            output.append(header + "{" + body + "}")
        cursor = closing + 1
    return "".join(output)


def main() -> None:
    for name in SOURCES:
        source = ROOT / "assets" / "css" / f"{name}.css"
        destination = source.with_name(f"{name}_classes.css")
        generated = (
            "/* Generated by tools/generate_class_css.py. Do not edit directly. */\n"
            f"/* Class-driven equivalent of {name}.css for browsers without style queries. */\n\n"
            + transform(source.read_text(), name)
        )
        generated = "\n".join(line.rstrip() for line in generated.splitlines()).rstrip() + "\n"
        destination.write_text(generated)
        print(destination.relative_to(ROOT))


if __name__ == "__main__":
    main()
