#!/usr/bin/env python3

import json
import re
import sys


source = sys.stdin.read()
expressions = []


def mask_expression(match):
    index = len(expressions)
    expressions.append(match.group(0))
    return json.dumps(f"__JINJA_EXPRESSION_{index}__")


masked = re.sub(r"{{-?\s*.*?\s*-?}}", mask_expression, source, flags=re.DOTALL)

try:
    document = json.loads(masked)
except json.JSONDecodeError as error:
    print(f"json-jinja formatter: invalid JSON template: {error}", file=sys.stderr)
    sys.exit(1)

formatted = json.dumps(document, indent=2, ensure_ascii=False)
for index, expression in enumerate(expressions):
    marker = json.dumps(f"__JINJA_EXPRESSION_{index}__")
    formatted = formatted.replace(marker, expression)

sys.stdout.write(formatted + "\n")
