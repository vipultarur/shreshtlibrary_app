import os, glob

path = r'd:\extra\shresht\student_app\lib\**\*.dart'

for filepath in glob.glob(path, recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content
        
        # Replace src/features/ with features/
        new_content = new_content.replace("'../features/", "'package:student_app/features/")
        new_content = new_content.replace("'../../features/", "'package:student_app/features/")
        new_content = new_content.replace("'package:student_app/src/features/", "'package:student_app/features/")

        if content != new_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated {filepath}')
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
