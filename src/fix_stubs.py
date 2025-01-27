import re
import sys


def read_file(file_path: str) -> str:
    with open(file_path, 'r') as file:
        return file.read()


def write_file(file_path: str, content: str) -> None:
    with open(file_path, 'w') as file:
        file.write(content)


def substitute_aravis_classes(mtch: re.Match, aravis_classes: set[str]) -> str:
    # Extract the matched text
    matched_text = mtch.group()
    # Prepend 'Aravis.' to it
    if matched_text in aravis_classes:
        return f'Aravis.{matched_text}'
    return matched_text  # Return the original text if not in the set


def main():
    if len(sys.argv) != 3:
        print('Usage: python3 fix_stubs.py <input_file> <output_file>')

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    file = read_file(input_file)

    # Find all the classes in the file
    aravis_classes = set(
        map(lambda x: x[6:], re.findall(r'^class [A-Z][a-zA-Z0-9]*', file, re.MULTILINE))
    )

    # Patterns to substitute:
    # -> Class
    # : Class
    # (Class)
    # [Class]
    # [Class,
    # , Class]
    # (Class,
    # , Class)
    pattern = r'(?<=-> )(\w+)|(?<=: )(\w+)|(?<=\()\w+(?=,)|(?<=, )\w+(?=\))|(?<=\()\w+(?=\))|(?<=\[|\s|,)(\w+)(?=\]|\s|,)'
    text_with_aravis_classes = re.sub(
        pattern, lambda mtch: substitute_aravis_classes(mtch, aravis_classes), file
    )

    # Find the first constant declaration
    content_start = re.search(r'^[A-Z0-9_]+:', text_with_aravis_classes, re.MULTILINE)
    output = text_with_aravis_classes[: content_start.start()]

    # Add class Aravis
    output += 'class Aravis:\n'

    # Add tab to every line after Aravis class
    output += re.sub(
        r'^', '    ', text_with_aravis_classes[content_start.start() :], flags=re.MULTILINE
    )

    write_file(output_file, output)


if __name__ == '__main__':
    main()
