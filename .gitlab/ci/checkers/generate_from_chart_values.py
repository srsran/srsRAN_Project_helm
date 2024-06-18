import yaml
import argparse
import json
from jsonschema import validate, ValidationError

def validate_yaml(input_json_schema, yaml_data):
    with open(input_json_schema, 'r', encoding="UTF8") as f:
        json_schema = json.load(f)

    try:
        validate(instance=yaml_data, schema=json_schema)
        print("YAML data is valid against the schema")
    except ValidationError as e:
        print("Validation error:", e)
        exit(1)
    print("Configuration parsed successfully")

def main():
    parser = argparse.ArgumentParser(description="Check chart configuratoin.")
    parser.add_argument('--input-chart-config', type=str, required=True, help='Path to the chart configuration file.')
    parser.add_argument('--output-config', type=str, required=True, help='Path to save the configuration.')
    args = parser.parse_args()

    with open(args.input_chart_config, 'r', encoding="UTF8") as f:
        chart_config = f.read()

    config_yaml = None
    for config in chart_config.split("---\n"):
        if not "kind: ConfigMap" in config:
            continue
        config_yaml = yaml.safe_load(yaml.safe_load(config)["data"]["gnb-config.yml"])

    with open(args.output_config, "w", encoding="UTF8") as f:
        yaml.dump(config_yaml, f)

if __name__ == "__main__":
    main()