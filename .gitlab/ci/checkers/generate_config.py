import yaml
import re
import argparse
import json
import textwrap

def parse_config_from_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
        
    # Regex to find the [CONFIG  ] block and capture everything up to the next timestamp
    config_pattern = re.compile(r'\[CONFIG\s*\](.*?)\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+', re.DOTALL)
    match = config_pattern.search(content)
    
    if match:
        config_text = match.group(1).strip()
        # Remove the first line
        config_lines = config_text.split('\n')
        config_text = '\n'.join(config_lines[1:]).strip()
        try:
            config_data = yaml.safe_load(config_text)
            return config_data
        except yaml.YAMLError as e:
            print(f"Error parsing YAML: {e}")
            return None
    else:
        print("Configuration block not found")
        return None

def generate_template(data, prefix="Values.config", indent=0):
    template = ""
    indent_str = "  " * indent
    for key, value in data.items():
        if isinstance(value, dict):
            template += f"\n{indent_str}{{{{- if .{prefix}.{key} }}}}\n{indent_str}{key}:\n"
            template += generate_template(value, f"{prefix}.{key}", indent + 1)
            template += f"{indent_str}{{{{- end }}}}\n"
        else:
            template += f"{indent_str}{{{{- if .{prefix}.{key} }}}}\n{indent_str}{key}: {{{{ .{prefix}.{key} }}}}\n{indent_str}{{{{- end }}}}\n"
    return template

def generate_schema(data):
    def _generate_schema(data):
        schema = {"type": "object", "properties": {}, "additionalProperties": False}
        for key, value in data.items():
            if isinstance(value, dict):
                schema["properties"][key] = _generate_schema(value)
            elif isinstance(value, list):
                if len(value) > 0 and isinstance(value[0], dict):
                    schema["properties"][key] = {"type": "array", "items": _generate_schema(value[0])}
                else:
                    schema["properties"][key] = {"type": "array", "items": {"type": "string"}}
            elif isinstance(value, int):
                schema["properties"][key] = {"type": "integer"}
            elif isinstance(value, float):
                schema["properties"][key] = {"type": "number"}
            elif isinstance(value, bool):
                schema["properties"][key] = {"type": "boolean"}
            else:
                schema["properties"][key] = {"type": "string"}
        return schema

    base_schema = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": _generate_schema(data)["properties"],
        "additionalProperties": False
    }
    return base_schema

def main():
    parser = argparse.ArgumentParser(description="Parse configuration file and generate Jinja2 template.")
    parser.add_argument('--input', type=str, required=True, help='Path to the log file.')
    parser.add_argument('--mode', choices=['parse', 'configMap', 'schema'], required=True, help='Mode of operation: "parse" or "template".')
    args = parser.parse_args()

    config_data = parse_config_from_file(args.input)

    if not config_data:
        print("No configuration found or error parsing YAML.")
        return

    if args.mode == 'parse':
        print(json.dumps(config_data, indent=4))
    elif args.mode == 'schema':
        schema = generate_schema(config_data)
        print(json.dumps(schema, indent=4))
    elif args.mode == 'configMap':
        template = generate_template(config_data)
        full_template = f"""#
# Copyright 2021-2024 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

apiVersion: v1
kind: ConfigMap
metadata:
  name: srsgnb-configmap
data:
  gnb-config.yml: |
{textwrap.indent(template, '    ')}
    """
        print(full_template)

if __name__ == "__main__":
    main()