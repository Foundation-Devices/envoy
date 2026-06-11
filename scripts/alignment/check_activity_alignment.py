#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Verify Activity-row alignment from a `maestro hierarchy` dump.

Reads the JSON tree that `maestro hierarchy` prints on stdout (piped to this
script's stdin) while the app is showing the Activity tab, locates the first
transaction row, and checks that:

  1. the right column's primary amount is top-aligned with the left column's
     title (the ENV-2187 regression), and
  2. the secondary fiat line is top-aligned with the subtitle/date, within a
     looser tolerance that absorbs the designed EnvoySpacing.xs (4 logical px)
     offset of the fiat line.

Element matching is heuristic (text patterns + geometry) because nothing in
the app marks these nodes for us:

  * anchor   — the topmost node whose text is a transaction title
               (Received / Sent / Canceling / Canceled / Boosted /
               "Sent (Boosted)");
  * amount   — the topmost numeric node vertically level with the anchor in
               the right part of the screen;
  * subtitle — has no standalone node (it merges into the row container),
               so its top is derived as the anchor's bottom edge: the left
               column is a gapless Column, the subtitle starts where the
               title box ends;
  * fiat     — the topmost numeric right-half node below the amount, within
               the first row's band (bounded by the next row's title).

Bounds in the hierarchy are physical pixels, so logical tolerances are scaled
by --density-scale (devicePixelRatio, i.e. android density / 160).

Exit codes: 0 aligned, 1 misaligned, 2 could not locate the expected nodes
(e.g. no transaction row on screen, balances hidden, or fiat OFF).
"""

import argparse
import json
import re
import sys

# The six titles getTransactionTitleText can emit: Received, Sent,
# Sent (Boosted), Canceling, Canceled, Boosted.
TITLE_RE = re.compile(
    r"^(Received|Sent|Canceling|Canceled|Boosted)( \(.+\))?$")
BOUNDS_RE = re.compile(r"\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]")


def collect_text_nodes(node, out):
    attrs = node.get("attributes", {}) or {}
    text = (attrs.get("text") or attrs.get("accessibilityText") or "").strip()
    bounds = attrs.get("bounds") or ""
    m = BOUNDS_RE.search(bounds)
    if text and m:
        left, top, right, bottom = map(int, m.groups())
        if right > left and bottom > top:
            out.append({"text": text, "left": left, "top": top,
                        "right": right, "bottom": bottom})
    for child in node.get("children", []) or []:
        collect_text_nodes(child, out)


def parse_hierarchy(raw):
    # maestro may print log lines around the JSON; isolate the outermost tree.
    start, end = raw.find("{"), raw.rfind("}")
    if start == -1 or end <= start:
        fail_locate("any JSON in the hierarchy input")
    return json.loads(raw[start:end + 1])


def fail_locate(what):
    print(f"✗ Could not locate {what} in the hierarchy.", file=sys.stderr)
    print("  Is the Activity tab showing a transaction row with a visible "
          "balance and fiat ON?", file=sys.stderr)
    sys.exit(2)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--density-scale", type=float, default=1.0,
                    help="devicePixelRatio used to scale logical tolerances")
    ap.add_argument("--top-tolerance", type=float, default=2.0,
                    help="logical px; title vs primary amount tops")
    ap.add_argument("--bottom-tolerance", type=float, default=6.0,
                    help="logical px; subtitle vs fiat tops (4px design "
                         "offset + slack)")
    args = ap.parse_args()

    root = parse_hierarchy(sys.stdin.read())
    nodes = []
    collect_text_nodes(root, nodes)
    if not nodes:
        fail_locate("any text nodes")

    screen_right = max(n["right"] for n in nodes)

    # Multi-line matches are merged container nodes, not the title itself.
    titles = [n for n in nodes
              if "\n" not in n["text"] and TITLE_RE.match(n["text"])]
    if not titles:
        fail_locate("a transaction title (Received/Sent/...)")
    titles.sort(key=lambda n: n["top"])
    anchor = titles[0]
    row_h = anchor["bottom"] - anchor["top"]

    # Everything we want lives in the first row's band: from the anchor down
    # to the next row's title (or a generous fallback when there is only one
    # transaction). Without this bound, the matcher can drift into row 2 —
    # or onto system overlays like Samsung's "Edge panels" handle.
    band_end = (titles[1]["top"] if len(titles) > 1
                else anchor["top"] + 6 * row_h)

    def in_band(n):
        return anchor["top"] - row_h / 2 <= n["top"] < band_end

    has_digit = re.compile(r"\d")

    # Amount: vertically level with the anchor, ending in the right ~40% of
    # the screen, and actually numeric (excludes overlay nodes such as
    # "Edge panels"); prefer the candidate closest to the anchor's top.
    amount_cands = [n for n in nodes if n is not anchor
                    and in_band(n)
                    and abs(n["top"] - anchor["top"]) <= row_h
                    and n["right"] >= screen_right * 0.6
                    and n["left"] > anchor["right"]
                    and has_digit.search(n["text"])]
    if not amount_cands:
        fail_locate("the primary amount (is the balance hidden?)")
    amount = min(amount_cands,
                 key=lambda n: (abs(n["top"] - anchor["top"]), -n["right"]))

    scale = args.density_scale
    top_tol = args.top_tolerance * scale
    top_diff = abs(amount["top"] - anchor["top"])

    print(f"  title   '{anchor['text']}': top={anchor['top']}px")
    print(f"  amount  '{amount['text']}': top={amount['top']}px")
    print(f"  top diff: {top_diff:.0f}px (tolerance {top_tol:.0f}px physical"
          f" = {args.top_tolerance}px logical)")

    ok = True
    if top_diff > top_tol:
        print("✗ TOP MISALIGNED: amount is "
              f"{(amount['top'] - anchor['top']) / scale:+.1f} logical px "
              "from the title")
        ok = False

    # The subtitle has NO standalone node: EnvoyListTile gives the title its
    # own Semantics container, but the subtitle merges into the full-row
    # container node, whose bounds span the whole row. Its real top edge is
    # still recoverable by construction: the left column is a gapless
    # Column, so the subtitle starts exactly at the title's bottom edge.
    subtitle_top = anchor["bottom"]

    # Fiat: topmost numeric node below the amount, in the right half of the
    # screen, inside the band. The left > 50% guard keeps full-width row
    # containers (whose merged label can contain digits, e.g. "3 hours
    # ago") out of the candidate set.
    fiat_cands = [n for n in nodes if n is not amount
                  and in_band(n)
                  and n["top"] > amount["top"] + row_h / 2
                  and n["left"] > screen_right * 0.5
                  and has_digit.search(n["text"])]
    if not fiat_cands:
        fail_locate("the fiat line (is fiat ON?)")
    fiat = min(fiat_cands, key=lambda n: n["top"])

    bottom_tol = args.bottom_tolerance * scale
    bottom_diff = abs(fiat["top"] - subtitle_top)

    print(f"  subtitle top (= title bottom): {subtitle_top}px")
    print(f"  fiat     '{fiat['text']}': top={fiat['top']}px")
    print(f"  bottom diff: {bottom_diff:.0f}px (tolerance {bottom_tol:.0f}px"
          f" physical = {args.bottom_tolerance}px logical)")

    if bottom_diff > bottom_tol:
        print("✗ BOTTOM MISALIGNED: fiat is "
              f"{(fiat['top'] - subtitle_top) / scale:+.1f} logical px "
              "from the subtitle")
        ok = False

    if not ok:
        sys.exit(1)
    print("✓ Activity row columns are top-aligned")


if __name__ == "__main__":
    main()
