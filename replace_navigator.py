import os
import re

def replace_navigator(text):
    # import go_router if not already present
    if "Navigator." in text and "go_router.dart" not in text:
        # insert go_router import after the last import
        import_stmt = "import 'package:go_router/go_router.dart';\n"
        if "package:flutter/material.dart" in text:
            text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)
    
    # Navigator.pushNamed(context, route) -> context.push(route)
    text = re.sub(r'Navigator\.pushNamed\(\s*context\s*,\s*([^\)]+)\)', r'context.push(\1)', text)
    # Navigator.of(context).pushNamed(route) -> context.push(route)
    text = re.sub(r'Navigator\.of\(context\)\.pushNamed\(\s*([^\)]+)\)', r'context.push(\1)', text)
    
    # Navigator.pushNamedAndRemoveUntil(context, route, ...) -> context.go(route)
    text = re.sub(r'Navigator\.pushNamedAndRemoveUntil\(\s*context\s*,\s*([^,]+)\s*,\s*[^\)]+\)', r'context.go(\1)', text)
    # Navigator.of(context).pushNamedAndRemoveUntil(route, ...) -> context.go(route)
    text = re.sub(r'Navigator\.of\(context\)\.pushNamedAndRemoveUntil\(\s*([^,]+)\s*,\s*[^\)]+\)', r'context.go(\1)', text)
    
    # Navigator.pop(context) -> context.pop()
    text = re.sub(r'Navigator\.pop\(\s*context\s*\)', r'context.pop()', text)
    # Navigator.of(context).pop() -> context.pop()
    text = re.sub(r'Navigator\.of\(context\)\.pop\(\)', r'context.pop()', text)

    # Navigator.of(context).pop(...) -> context.pop(...)
    text = re.sub(r'Navigator\.of\(context\)\.pop\(([^)]+)\)', r'context.pop(\1)', text)
    # Navigator.pop(context, ...) -> context.pop(...)
    text = re.sub(r'Navigator\.pop\(\s*context\s*,\s*([^)]+)\)', r'context.pop(\1)', text)

    return text

def process_dir(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                # skip app.dart and app_routes.dart since they are already updated/configured
                if file in ['app.dart', 'app_routes.dart', 'main.dart']:
                    continue
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = replace_navigator(content)
                
                if content != new_content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)

if __name__ == "__main__":
    process_dir("lib")
