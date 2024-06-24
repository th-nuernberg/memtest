import click
import secrets
import json
import os

@click.command()
@click.argument('studienname')
@click.option('--output', default='studykey.json', help='Output JSON file name')
@click.option('--remove', is_flag=True, help='Remove the key-value pair with the given studienname')
def manage_studykey(studienname, output, remove):
    # Load existing data if the file exists
    if os.path.exists(output):
        with open(output, 'r') as json_file:
            data = json.load(json_file)
    else:
        data = []

    if remove:
        # Remove the key-value pair with the given studienname
        data = [item for item in data if item['studienname'] != studienname]
        print(f"Key-value pair with studienname '{studienname}' has been removed.")
    else:
        # Generate a secret token
        secret = secrets.token_urlsafe(16)
        
        # Create the key-value pair
        key_value_pair = {
            "studienname": studienname,
            "secret": secret
        }

        # Append the new key-value pair
        data.append(key_value_pair)
        print(f"Key-value pair with studienname '{studienname}' has been added.")

    # Save the updated JSON array to the file
    with open(output, 'w') as json_file:
        json.dump(data, json_file, indent=4)
    
    print(f"JSON data has been updated in {output}")

if __name__ == '__main__':
    manage_studykey()
