import json

with open('C:\\Users\\dejunai\\projects\\repo\\KB0RXF\\acf-export-2026-05-06.Media Entry.json', 'r') as f:
    data = json.load(f)

fields = data[0]['fields']

# Create the new master category field
category_field = {
    "key": "field_category_master",
    "label": "Recording Category",
    "name": "recording_category",
    "type": "select",
    "instructions": "Select the type of recording to show relevant fields.",
    "required": 1,
    "choices": {
        "broadcast": "Commercial / Public Broadcast",
        "shortwave": "Shortwave / DX / Bounces",
        "scanner": "Police / Scanner / Dispatch",
        "other": "Non-Broadcast / Found Audio"
    },
    "default_value": "broadcast",
    "return_format": "value",
    "wrapper": {"width": "", "class": "", "id": ""}
}

new_fields = [category_field]

# Add conditional logic to existing fields
for f in fields:
    name = f['name']
    
    # Reset conditional logic
    f['conditional_logic'] = 0
    
    if name in ['station', 'show_name', 'talent_dj']:
        f['conditional_logic'] = [
            [{"field": "field_category_master", "operator": "==", "value": "broadcast"}],
            [{"field": "field_category_master", "operator": "==", "value": "shortwave"}]
        ]
        if name == 'station':
            f['label'] = 'Station / Broadcaster'
    
    elif name in ['time_utc', 'receiver']:
        f['conditional_logic'] = [
            [{"field": "field_category_master", "operator": "==", "value": "shortwave"}],
            [{"field": "field_category_master", "operator": "==", "value": "scanner"}]
        ]
    
    elif name in ['frequency']:
        f['conditional_logic'] = [
            [{"field": "field_category_master", "operator": "==", "value": "broadcast"}],
            [{"field": "field_category_master", "operator": "==", "value": "shortwave"}],
            [{"field": "field_category_master", "operator": "==", "value": "scanner"}]
        ]
        
    elif name in ['station_location']:
        f['conditional_logic'] = [
            [{"field": "field_category_master", "operator": "==", "value": "broadcast"}],
            [{"field": "field_category_master", "operator": "==", "value": "shortwave"}]
        ]
        f['label'] = 'Station / Signal Origin'

    new_fields.append(f)

data[0]['fields'] = new_fields
data[0]['title'] = "Media Meta V3 (Bulletproof)"

with open('C:\\Users\\dejunai\\projects\\repo\\KB0RXF\\acf-v3-bulletproof.json', 'w') as f:
    json.dump(data, f, indent=4)

print("ACF JSON updated successfully.")
