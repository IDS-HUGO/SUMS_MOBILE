import os
import re

def remove_comments(text):
    # Regex to match:
    # 1. Strings (single or double quotes, handling escapes)
    # 2. Block comments
    # 3. Line comments
    pattern = r'(".*?"|\'.*?\')|(/\*.*?\*/|//[^\r\n]*)'
    # compile with re.DOTALL for block comments
    regex = re.compile(pattern, re.DOTALL | re.MULTILINE)

    def replacer(match):
        # If the 2nd group (comments) is matched, remove it.
        # Otherwise, keep the 1st group (strings).
        if match.group(2) is not None:
            return ""
        else:
            return match.group(1)
            
    result = regex.sub(replacer, text)
    # Remove multiple empty lines
    result = re.sub(r'\n\s*\n', '\n', result)
    return result

def process_dir(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = remove_comments(content)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)

if __name__ == "__main__":
    process_dir("lib")
