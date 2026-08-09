#!/usr/bin/env python3

import json
import re
import sys


source = sys.stdin.read()
expressions = []
lint_mode = "--lint" in sys.argv[1:]


def inside_json_string(position):
    in_string = False
    escaped = False
    for character in source[:position]:
        if character == "\\" and not escaped:
            escaped = True
            continue
        if character == '"' and not escaped:
            in_string = not in_string
        escaped = False
    return in_string


def mask_expression(match):
    index = len(expressions)
    expressions.append(match.group(0))
    marker = f"__JINJA_EXPRESSION_{index}__"
    return marker if inside_json_string(match.start()) else json.dumps(marker)


masked = re.sub(r"{{-?\s*.*?\s*-?}}", mask_expression, source, flags=re.DOTALL)

try:
    document = json.loads(masked)
except json.JSONDecodeError as error:
    if lint_mode:
        print(f"{error.lineno}:{error.colno}: invalid JSON template: {error.msg}", file=sys.stderr)
    else:
        print(f"json-jinja formatter: invalid JSON template: {error}", file=sys.stderr)
    sys.exit(1)

if lint_mode:
    sys.exit(0)

formatted = json.dumps(document, indent=2, ensure_ascii=False)
for index, expression in enumerate(expressions):
    marker = json.dumps(f"__JINJA_EXPRESSION_{index}__")
    formatted = formatted.replace(marker, expression)
    formatted = formatted.replace(marker[1:-1], expression)

sys.stdout.write(formatted + "\n")
